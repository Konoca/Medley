import concurrent.futures
import yt_dlp as yt
from flask import Flask, request, jsonify
from youtubesearchpython import VideosSearch

import platforms.youtube as youtube
import platforms.spotify as spotify

app = Flask(__name__)

# Fetch updated stream link for specific song and platform
def fetch_stream_obj(platform: int, codec: str, id: str):
    url = ''
    if platform == 1:
        url = f'https://youtube.com/watch?v={id}'

    if platform == 2:
        results = VideosSearch(id, limit=1)
        result = results.result().get('result', [])
        url = result[0].get('link', '') if result != [] else f'ytsearch1:{id}'

    if platform == 3:
        url = f'https://soundcloud.com/{id}'

    try:
        data = yt.YoutubeDL({'format': codec, 'quiet': 'True'}).extract_info(url, download=False)
        return {
            'id': id,
            'platform': platform,
            'url': data['entries'][0]['url'] if url.startswith('ytsearch1:') else data['url']
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
            processes.append(
                executor.submit(
                    fetch_stream_obj,
                    item['platform'],
                    item['codec'],
                    item['id'],
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

# get a list of search results
@app.route('/api/search', methods=['GET'])
def search():
    query = request.args.get('q', '')
    limit = int(request.args.get('limit', '5'))
    token = request.args.get('sp_token', '')
    platforms = request.args.get('platforms', '').split(',')

    results = {}
    results['platforms'] = platforms
    # print(platforms)

    results['1'] = youtube.search(query, limit) if '1' in platforms else []
    results['2'] = spotify.search(query, limit, token) if token and '2' in platforms else []

    # TODO Soundcloud Support
    results['3'] = []

    return jsonify(results)

# Main Thread
if __name__ == '__main__':
    app.run(host='0.0.0.0')

