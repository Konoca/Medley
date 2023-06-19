from flask import Flask, request, jsonify
import concurrent.futures
import yt_dlp as yt

import platform_functions.youtube as youtube

app = Flask(__name__)

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
                    item['id']
                )
            )
        for process in processes:
            response.append(process.result())
    return jsonify(response)


def fetch_stream_obj(platform: int, codec: str, id: str):
    if platform == 1:
        url = f'https://youtube.com/watch?v={id}'

    # TODO Spotify Support  
    if platform == 2:
        return
    
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


@app.route('/api/get_playlists', methods=['GET'])
def get_playlists():
    platform = request.args.get('platform')
    token = request.args.get('token')

    playlists = []

    if platform == '1':
        playlists = youtube.get_playlists(token)

    # TODO Spotify Support
    # TODO Soundcloud Support

    return jsonify(playlists)


@app.route('/api/get_songs', methods=['GET'])
def get_songs():
    platform = request.args.get('platform')
    token = request.args.get('token')
    playlistId = request.args.get('playlistId')

    songs = []

    if platform == '1':
        songs = youtube.get_videos(token, playlistId)

    # TODO Spotify Support
    # TODO Soundcloud Support

    return jsonify(songs)


if __name__ == '__main__':
    app.run(host='0.0.0.0')

