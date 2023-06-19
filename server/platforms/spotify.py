import requests
import json
import concurrent.futures

API = 'https://api.spotify.com/v1/'

def get_playlists(token: str, user: str, song_data: bool):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(API + f'users/{user}/playlists', headers=headers)
    playlists = []

    if response.status_code == 200:
        body = json.loads(response.content)
        processes = []

        with concurrent.futures.ProcessPoolExecutor() as executor:
            for i in body['items']:
                processes.append(
                    executor.submit(_parse_playlist, i, song_data, headers)
                )
        
        for process in processes:
            result = process.result()
            if result: playlists.append(result)

        return playlists
    else:
        return {'error': f'spotify playlist error {response.status_code}'}
    
def _parse_playlist(playlist, song_data, headers):
    id = playlist['id']
    songs = playlist['tracks']['total']

    if song_data:
        response = requests.get(API + f'playlists/{id}/tracks', headers=headers)

        if response.status_code == 200:
            body = json.loads(response.content)
            songs = []

            for i in body['items']:
                songs.append({
                    'song_id': i['track']['id'],
                    'song_title': i['track']['name'],
                    'artist': i['track']['artists'][0]['name'],
                    'thumbnail': i['track']['album']['images'][0]['url'],
                    'duration': i['track']['duration_ms']
                })

    return {
        'platform': '2',
        'playlist_id': id,
        'playlist_name': playlist['name'],
        'thumbnail': playlist['images'][0]['url'],
        'songs': songs
    }
