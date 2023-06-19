import requests
import json
import concurrent.futures

API = 'https://api.spotify.com/v1/'

def get_playlists(token: str, user: str, scope: bool):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(API + f'users/{user}/playlists', headers=headers)
    playlists = []

    if response.status_code == 200:
        body = json.loads(response.content)
        processes = []

        with concurrent.futures.ProcessPoolExecutor() as executor:
            for i in body['items']:
                processes.append(
                    executor.submit(_parse_playlist, token, i, scope)
                )
        
        for process in processes:
            result = process.result()
            if result: playlists.append(result)

        return playlists
    else:
        return {'error': f'spotify playlist error {response.status_code}'}

def get_songs(token: str, playlistId: str):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(API + f'playlists/{playlistId}/tracks', headers=headers)
    songs = []

    if response.status_code == 200:
        body = json.loads(response.content)

        for i in body['items']:
            songs.append({
                'platform': '2',
                'song_id': i['track']['id'],
                'song_title': i['track']['name'],
                'artist': i['track']['artists'][0]['name'],
                'thumbnail': i['track']['album']['images'][0]['url'],
                'duration': i['track']['duration_ms']
            })
        return songs
    else: 
        return {'error': f'spotify songs error {response.status_code}'}


def _parse_playlist(token, playlist, scope):
    id = playlist['id']
    songs = playlist['tracks']['total']

    if scope:
        songs = get_songs(token, id)

    return {
        'platform': '2',
        'playlist_id': id,
        'playlist_name': playlist['name'],
        'thumbnail': playlist['images'][0]['url'],
        'songs': songs
    }
