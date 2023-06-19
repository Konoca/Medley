import os
import json
import requests
import concurrent.futures
import yt_dlp as yt
import mysql.connector
from flask import Flask, request, jsonify
from dotenv import load_dotenv

import platforms.youtube as youtube
import platforms.spotify as spotify

# Environment variables
load_dotenv()

SQL_USERNAME = os.getenv('SQL_USERNAME')
SQL_PASSWORD = os.getenv('SQL_PASSWORD')

# Initialization
app = Flask(__name__)
cnx = mysql.connector.connect(
        host = '127.0.0.1',
        user = SQL_USERNAME, 
        password = SQL_PASSWORD
      )

# Fetch updated stream link for specific song and platform
def fetch_stream_obj(platform: int, codec: str, id: str, token: str):
    if platform == 1:
        url = f'https://youtube.com/watch?v={id}'

    if platform == 2:
        url = f'https://api.spotify.com/v1/tracks/{id}'
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            body = json.loads(response.content)
            return {
                'id': id,
                'platform': platform,
                'url': body['preview_url']
            }
        else:
            return response.json()
    
    if platform == 3:
        url = f'https://soundcloud.com/{id}'

    try:
        data = yt.YoutubeDL({'format': codec, 'quiet': 'True'}).extract_info(url, download=False)
        return {
            'id': id,
            'platform': platform,
            'url': data['url']
        }
    except Exception as e:
        return


# API REQUESTS

# Get streaming information for a list of songs
@app.route('/api/stream', methods=['POST'])
def stream():
    data = request.get_json()
    processes = []
    response = []

    with concurrent.futures.ProcessPoolExecutor() as executor:
        for item in data:
            token = ''
            try: token = item['token']
            except: token = ''
            processes.append(
                executor.submit(
                    fetch_stream_obj,
                    item['platform'],
                    item['codec'],
                    item['id'],
                    token
                )
            )
        for process in processes:
            response.append(process.result())
    return jsonify(response)

# Get a users playlists with the option to include song data
@app.route('/api/get_playlists', methods=['GET'])
def get_playlists():
    platform = request.args.get('platform')
    token = request.args.get('token')
    scope = request.args.get('scope') == 'all'

    playlists = []

    if platform == '1':
        playlists = youtube.get_playlists(token, scope)

    if platform == '2':
        user = request.args.get('user')
        playlists = spotify.get_playlists(token, user, scope)

    # TODO Soundcloud Support

    return jsonify(playlists)

# Get a list of songs within a specific playlist
@app.route('/api/get_songs', methods=['GET'])
def get_songs():
    platform = request.args.get('platform')
    token = request.args.get('token')
    playlistId = request.args.get('playlistId')

    songs = []

    if platform == '1':
        songs = youtube.get_videos(token, playlistId)

    if platform == '2':
        songs = spotify.get_songs(token, playlistId)

    # TODO Soundcloud Support

    return jsonify(songs)

# Main Thread
if __name__ == '__main__':
    if cnx.is_connected(): 
        print('[Medley] Connected to database')
    app.run(host='0.0.0.0')
