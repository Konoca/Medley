#!./venv/bin/python3

from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.get("/stream")
def get_stream():
    platform = request.args.get('platform')
    id = request.args.get('id')
    codec = request.args.get('codec')

    try:
        print(platform, id, codec)
        if platform == '1':
            url = f'https://youtube.com/watch?v={id}'
        if platform == '3':
            url = f'https://soundcloud.com/{id}'
        link = subprocess.check_output(['yt-dlp', '-f', codec, '-g', url])
        print(link.decode('utf-8')[:-1])
        return jsonify({'url': link.decode('utf-8')[:-1]})
    except Exception as e:
        print(e)
        return jsonify({})

app.run()

