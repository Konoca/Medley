import requests
import json
import concurrent.futures

API = 'https://api.spotify.com/v1/'


def get_playlists(token: str, user: str, scope: bool):
    headers = {'Authorization': f'Bearer {token}'}

    playlists = []
    processes = []
    url = API + f'users/{user}/playlists'

    # playlists
    while True:
        response = requests.get(url, headers=headers)
        if (response.status_code != 200):
            break

        body = json.loads(response.content)
        items = body.get('items', [])

        with concurrent.futures.ProcessPoolExecutor() as executor:
            for item in items:
                processes.append(
                    executor.submit(
                        _parse_playlist,
                        token,
                        item,
                        scope,
                        'playlists',
                    )
                )

        url = body.get('next', '')
        if not url:
            break

    # saved albums
    url = API + 'me/albums'
    while True:
        response = requests.get(url, headers=headers)
        if (response.status_code != 200):
            break

        body = json.loads(response.content)
        items = body.get('items', [])

        with concurrent.futures.ProcessPoolExecutor() as executor:
            for item in items:
                processes.append(
                    executor.submit(
                        _parse_playlist,
                        token,
                        item['album'],
                        scope,
                        'albums',
                    )
                )

        url = body.get('next', '')
        if not url:
            break

    for process in processes:
        result = process.result()
        if result: playlists.append(result)

    return playlists


def get_songs(token: str, playlistId: str):
    headers = {'Authorization': f'Bearer {token}'}

    songs = []
    processes = []
    url = API + f'{playlistId}/tracks'

    while True:
        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            break

        body = json.loads(response.content)
        items = body.get('items', [])

        with concurrent.futures.ProcessPoolExecutor() as executor:
            for item in items:
                processes.append(
                    executor.submit(
                        _parse_song,
                        item,
                    )
                )
        url = body.get('next', '')
        if not url:
            break

    for process in processes:
        result = process.result()
        if result: songs.append(result)

    return songs


def _parse_playlist(token, playlist, scope, playlist_type):
    id = playlist_type + '/' + playlist['id']
    songs = playlist['tracks']['total']

    if scope:
        songs = get_songs(token, id)

    return {
        'platform': '2',
        'playlist_id': id,
        'playlist_name': playlist['name'],
        'thumbnail': playlist['images'][0]['url'] if playlist.get('images') != [] else '',
        'songs': songs
    }


def _parse_song(song):
    try:
        i = song['track'] if song.get('track') else song
        artists = ', '.join([artist.get('name', '') for artist in i.get('artists', [])])
        title = i.get('name', '')
        return {
            'platform': '2',
            'song_id': f'{title} {artists}',
            'song_title': i['name'],
            'artist': artists,
            'thumbnail': i['album']['images'][0]['url'] if i.get('album', {}).get('images', []) != [] else '',
            'duration': i['duration_ms']
        }
    except Exception as e:
        # print(song)
        print(e)
        return

