import requests
import json
import concurrent.futures
from youtubesearchpython import VideosSearch

API = 'https://youtube.googleapis.com/youtube/v3/'

def get_playlists(token: str, scope: bool):
    headers = {'Authorization': f'Bearer {token}'}

    playlists = []
    processes = []
    nextPageToken = ''

    while True:
        response = requests.get(API + 'playlists', headers=headers, params={
            'part': 'snippet',
            'mine': 'true',
            'maxResults': 50,
            'pageToken': nextPageToken
        })

        if response.status_code != 200:
            print(json.dumps(response.json(), indent=2))
            break

        body = (json.loads(response.content))
        items = body.get('items', [])

        with concurrent.futures.ProcessPoolExecutor() as executor:
            for item in items:
                processes.append(
                    executor.submit(
                        _parse_playlist,
                        item,
                        token,
                        scope
                    )
                )

        nextPageToken = body.get('nextPageToken', '')
        if nextPageToken == '':
            break

    for process in processes:
        result = process.result()
        if result: playlists.append(result)

    return playlists


def get_videos(token: str, playlistId: str):
    headers = {'Authorization': f'Bearer {token}'}

    videos = []
    processes = []
    nextPageToken = ''

    while True:
        response = requests.get(API + 'playlistItems', headers=headers, params={
            'part': 'snippet,contentDetails,status',
            'playlistId': playlistId,
            'maxResults': 50,
            'pageToken': nextPageToken
        })

        if response.status_code != 200:
            break

        body = (json.loads(response.content))
        items = body.get('items', [])

        with concurrent.futures.ProcessPoolExecutor() as executor:
            for item in items:
                processes.append(
                    executor.submit(
                        _parse_video,
                        item,
                        headers
                    )
                )

        nextPageToken = body.get('nextPageToken', '')
        if nextPageToken == '':
            break

    for process in processes:
        result = process.result()
        if result: videos.append(result)
    
    return videos


def _parse_video(video, headers):
    if video['status']['privacyStatus'] != 'public':
        return
    
    response = requests.get(API + 'videos', headers=headers, params={
        'part': 'contentDetails',
        'id': video['snippet']['resourceId']['videoId']
    })

    if response.status_code != 200:
        return
    
    body = json.loads(response.content)
    
    return {
        'platform': '1',
        'song_id': video['snippet']['resourceId']['videoId'],
        'song_title': video['snippet']['title'],
        'artist': video['snippet']['videoOwnerChannelTitle'],
        'duration': body['items'][0]['contentDetails']['duration'],
        'thumbnail': video['snippet']['thumbnails'].get('high', {}).get('url', '')
    }


def _parse_playlist(playlist, token, scope):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(API + 'playlistItems', headers=headers, params={
        'part': 'snippet',
        'playlistId': playlist['id']
    })

    if response.status_code != 200:
        return
    
    body = json.loads(response.content)
    songs = body['pageInfo']['totalResults']
    if scope: 
        songs = get_videos(token, playlist['id'])
    
    return {
        'platform': '1',
        'playlist_id': playlist['id'],
        'playlist_name': playlist['snippet']['title'],
        'thumbnail': playlist['snippet']['thumbnails']['high']['url'],
        'songs': songs
    }


def search(query: str, limit: int):
    results = VideosSearch(query, limit=limit)
    results = results.result().get('result', [])

    videos = []
    for r in results:
        videos.append({
            'platform': '1',
            'song_id': r['id'],
            'song_title': r['title'],
            'artist': r['channel']['name'],
            'duration': r['duration'],
            'thumbnail': r['thumbnails'][-1]['url']
        })

    return videos
