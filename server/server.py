import json
import os
import subprocess
import requests
import mysql.connector
from dotenv import load_dotenv
from flask import Flask, request, jsonify

load_dotenv()

SQL_USERNAME = os.getenv('SQL_USERNAME')
SQL_PASSWORD = os.getenv('SQL_USERNAME')
YOUTUBE_API_KEY = os.getenv('YOUTUBE_API_KEY')

app = Flask(__name__)
cnx = mysql.connector.connect(
        host = '127.0.0.1',
        user = SQL_USERNAME, 
        password = SQL_PASSWORD
      )

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
            link = subprocess.check_output(['yt-dlp', '-f', codec, '-g', url])
            response.append({'id': id, 'platform': platform, 'url': link.decode('utf-8')[:-1]})
        except Exception as e:
            print(e)
            return jsonify({'error': f'unable to get stream link from platform {platform} ({id})'})
    print(json.dumps(response, indent=2))
    return jsonify(response)

if __name__ == '__main__':
    if cnx.is_connected(): 
        print('[Medley] Connected to database')
    app.run(host='0.0.0.0')