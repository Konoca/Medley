from flask import Flask, request, jsonify
import concurrent.futures
import yt_dlp as yt

app = Flask(__name__)

@app.route('/api/stream', methods=['POST'])
def stream():
    data = request.get_json()
    response = []
    response2 = []
    with concurrent.futures.ProcessPoolExecutor() as executor:
        for item in data:
            response.append(
                executor.submit(
                    fetch_stream_obj,
                    item['platform'],
                    item['codec'],
                    item['id']
                )
            )
        for item in response:
            response2.append(item.result())
    return jsonify(response2)

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
        

if __name__ == '__main__':
    app.run()
    # app.run(host='0.0.0.0')