import json
import requests
import concurrent.futures
import yt_dlp as yt
from flask import Flask, request, jsonify
from youtubesearchpython import VideosSearch
from youtubesearchpython import Video

import platforms.youtube as youtube
import platforms.spotify as spotify

app = Flask(__name__)

# Fetch updated stream link for specific song and platform
def fetch_stream_obj(platform: int, codec: str, id: str, token: str):
    url = ''
    if platform == 1:
        url = f'https://youtube.com/watch?v={id}'

    if platform == 2:
        # url = f'https://open.spotify.com/track/{id}'
        url = f'https://api.spotify.com/v1/tracks/{id}'
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.get(url, headers=headers)

        if response.status_code != 200:
            return

        body = json.loads(response.content)

        artists = ' '.join([artist.get('name', '') for artist in body.get('artists', [])])
        title = body.get('name', '')
        results = VideosSearch(f'{title} {artists}', limit=1)
        result = results.result().get('result', [])
        url = result[0].get('link', '') if result != [] else f'ytsearch1:{title} {artists}'

    if platform == 3:
        url = f'https://soundcloud.com/{id}'

    try:
        data = yt.YoutubeDL({'format': codec, 'quiet': 'True'}).extract_info(url, download=False)
        return {
            'id': id,
            'platform': platform,
            'url': data['entries'][0]['url'] if url.startswith('ytsearch:1') else data['url']
        }
    except Exception as e:
        print('ERROR', e, data)
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
            processes.append(
                executor.submit(
                    fetch_stream_obj,
                    item['platform'],
                    item['codec'],
                    item['id'],
                    item.get('token', '')
                )
            )
        for process in processes:
            response.append(process.result())
    return jsonify(response)

# Get a users playlists with the option to include song data
@app.route('/api/get_playlists', methods=['GET'])
def get_playlists():
    platform = request.args.get('platform')
    token = request.args.get('token', '')
    scope = request.args.get('scope') == 'all'

    playlists = []

    if platform == '1':
        playlists = youtube.get_playlists(token, scope)

    if platform == '2':
        user = request.args.get('user', '')
        playlists = spotify.get_playlists(token, user, scope)

    # TODO Soundcloud Support

    return jsonify(playlists)

# Get a list of songs within a specific playlist
@app.route('/api/get_songs', methods=['GET'])
def get_songs():
    platform = request.args.get('platform')
    token = request.args.get('token', '')
    playlistId = request.args.get('playlistId', '')

    songs = []

    if platform == '1':
        songs = youtube.get_videos(token, playlistId)

    if platform == '2':
        songs = spotify.get_songs(token, playlistId)

    # TODO Soundcloud Support

    return jsonify(songs)

# Main Thread
if __name__ == '__main__':
    app.run(host='0.0.0.0')

