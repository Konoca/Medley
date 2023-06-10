import json
import os
import subprocess
import requests
import mysql.connector
from dotenv import load_dotenv
from flask import Flask, request, jsonify

# Environment variables
load_dotenv()

SQL_USERNAME = os.getenv('SQL_USERNAME')
SQL_PASSWORD = os.getenv('SQL_USERNAME')
YOUTUBE_API_KEY = os.getenv('YOUTUBE_API_KEY')

# Initialization
app = Flask(__name__)
cnx = mysql.connector.connect(
        host = '127.0.0.1',
        user = SQL_USERNAME, 
        password = SQL_PASSWORD
      )

# Returns temporary streaming link for audio player
@app.route('/api/stream', methods=['POST'])
def stream():
    data = request.get_json()
    response = []
    for item in data:
        platform = item['platform']
        codec = item['codec']
        id = item['id']

        try:
            if platform == 1:
                url = f'https://youtube.com/watch?v={id}'
            if platform == 3:
                url = f'https://soundcloud.com/{id}'
            # TODO: Spotify support
            link = subprocess.check_output(['yt-dlp', '-f', codec, '-g', url])
            response.append({'id': id, 'platform': platform, 'url': link.decode('utf-8')[:-1]})
        except Exception as e:
            # TODO: Error handling
            print(e)
            return jsonify({'error': f'unable to get stream link from platform {platform} ({id})'})
    return jsonify(response)

# Get user playlists based on platform
@app.route('/api/get_playlists', methods=['GET'])
def get_playlists():
    platform = request.args.get('platform')
    token = request.args.get('token')

    try:
        headers = { 'Authorization': f'Bearer {token}' }

        if platform == '1':
            url = 'https://youtube.googleapis.com/youtube/v3/'
            response = requests.get(url + 'playlists', headers=headers, params={ 'part': 'snippet', 'mine': 'true' })

            if response.status_code == 200:
                playlists = json.loads(response.content)
                playlists_response = []

                for item in playlists['items']:
                    song_resp = requests.get(url + 'playlistItems', headers=headers, params={'part': 'snippet', 'playlistId': item['id']})

                    if song_resp.status_code == 200:
                        songs = json.loads(song_resp.content)

                        playlists_response.append({
                            'platform': platform,
                            'playlist_id': item['id'],
                            'playlist_name': item['snippet']['title'],
                            'songs': songs['pageInfo']['totalResults'],
                        })
                    else:
                        return jsonify({'song error': song_resp.status_code})
                return jsonify(playlists_response)
            else:
                return jsonify({'playlist error': response.status_code})
            
        elif platform == '2':
            user = request.args.get('user') # will get from users table
            url = f'https://api.spotify.com/v1/users/{user}/playlists'
            response = requests.get(url, headers=headers)

            if response.status_code == 200:
                playlists = json.loads(response.content)
                playlists_response = []

                for item in playlists['items']:
                    playlists_response.append({
                            'platform': platform,
                            'playlist_id': item['id'],
                            'playlist_name': item['name'],
                            'songs': item['tracks']['total'],
                        })
                    
                print(json.dumps(playlists_response, indent=2))
                return jsonify(playlists_response)
            else:
                return jsonify({'playlist error': response.status_code})
        #TODO: Soundcloud support
    except Exception as e:
        # TODO: Error handling
        print(e)
        return jsonify({})
    return jsonify({})

# Get a list of songs within a playlist based on platform and playlist ID
@app.route('/api/get_songs', methods=['GET'])
def get_songs():
    platform = request.args.get('platform')
    token = request.args.get('token')
    playlistId = request.args.get('playlistId')
    headers = { 'Authorization': f'Bearer {token}' }

    try:
        if platform == '1':
            url = 'https://youtube.googleapis.com/youtube/v3/'

            response = requests.get(url + 'playlistItems', headers=headers, params={'part': 'snippet,contentDetails', 'playlistId': playlistId})
            if response.status_code == 200:
                songs = json.loads(response.content)
                songs_response = []

                for item in songs['items']:
                    video_resp = requests.get(url + 'videos', headers=headers, params={'part': 'contentDetails', 'id': item['snippet']['resourceId']['videoId']})

                    if video_resp.status_code == 200:
                        video = json.loads(video_resp.content)

                        songs_response.append({
                            'platform': platform,
                            'song_id': item['snippet']['resourceId']['videoId'],
                            'song_title': item['snippet']['title'],
                            'artist': item['snippet']['videoOwnerChannelTitle'],
                            'duration': video['items'][0]['contentDetails']['duration']
                        })
                    else:
                        return jsonify({'error': 'could not get song length'}), 404
                return jsonify(songs_response), 200
            else:
                return jsonify({'error': response.status_code})
        elif platform == '2':
            url = f'https://api.spotify.com/v1/playlists/{playlistId}/tracks'
            response = requests.get(url, headers=headers)

            if response.status_code == 200:
                songs = json.loads(response.content)
                songs_response = []

                for item in songs['items']:
                    songs_response.append({
                        'platform': platform,
                        'song_id': item['track']['id'],
                        'song_title': item['track']['name'],
                        'artist': item['track']['artists'][0]['name'],
                        'duration': item['track']['duration_ms']
                    })
                return jsonify(songs_response), 200
            else:
                return jsonify({'error': response.status_code}) 
        # TODO: Soundcloud support 
    except Exception as e:
        # TODO: Error handling
        print(e)
        return jsonify({})

# Main thread
if __name__ == '__main__':
    if cnx.is_connected(): 
        print('[Medley] Connected to database')
    app.run(host='0.0.0.0')