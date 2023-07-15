import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

import 'package:medley/objects/platform.dart';
import 'package:medley/objects/playlist.dart';
import 'package:medley/objects/song.dart';
import 'package:medley/providers/user_provider.dart';

final String serverUrl = dotenv.env['SERVER_URL']!;

class MedleyService {
  Future<SongCache> getStreamUrlBulk(List<Song> songs, SongCache cache,
      {String token = ''}) async {
    final Uri url = Uri.http(
      serverUrl,
      '/api/stream',
    );

    List<Map<String, dynamic>> body = [];
    for (Song song in songs) {
      body.add(
        {
          'platform': song.platform.id,
          'id': song.platformId,
          'codec': song.platform.codec,
          'token': token,
        },
      );
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    final jsonBody = json.decode(response.body);
    for (Map<String, dynamic> s in jsonBody) {
      if (s['id'] == null || s['platform'] == null || s['url'] == null) continue;
      cache.set(s['id'], s['platform'], s['url']);
    }

    return cache;
  }

  _getPlaylists(String accessToken, AudioPlatform platform, {user = ''}) async {
    final Uri url = Uri.http(
      serverUrl,
      '/api/get_playlists',
      {
        'platform': platform.id.toString(),
        'token': accessToken,
        'user': user,
      },
    );

    final response = await http.get(url);

    List<Playlist> playlists = [];
    for (Map<String, dynamic> pl in json.decode(response.body)) {
      playlists.add(Playlist.fromJson(pl));
    }

    return playlists;
  }

  Future<Playlist> getSongs(String accessToken, Playlist playlist) async {
    final Uri url = Uri.http(
      serverUrl,
      '/api/get_songs',
      {
        'platform': playlist.platform.id.toString(),
        'token': accessToken,
        'playlistId': playlist.listId,
      },
    );

    final response = await http.get(url);

    playlist.songs = json
        .decode(response.body)
        .map<Song>((s) => Song.fromJson(s, playlist.platform, playlist))
        .toList();

    playlist.numberOfTracks = playlist.songs.length;

    return playlist;
  }

  Future<List<Playlist>> getYoutubePlaylists(UserData user,
      {scope = ''}) async {
    if (!user.youtubeAccount.isAuthenticated) return [];
    return await _getPlaylists(
      user.youtubeAccount.accessToken,
      AudioPlatform.youtube(),
    );
  }

  Future<List<Playlist>> getSpotifyPlaylists(UserData user) async {
    if (!user.spotifyAccount.isAuthenticated) return [];
    return await _getPlaylists(
        user.spotifyAccount.accessToken, AudioPlatform.spotify(),
        user: await user.spotifyAccount.spotifyApi.me
            .get()
            .then((user) => user.id));
  }

  downloadSongs(Directory path, Playlist pl, AudioPlatform oldPlatform) async {
    final Uri url = Uri.http(
      serverUrl,
      '/api/stream',
    );

    List<Map<String, dynamic>> body = [];
    for (Song song in pl.songs) {
      body.add(
        {
          'platform': song.platform.id,
          'id': song.platformId,
          'codec': song.platform.codec,
        },
      );
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    final jsonBody = json.decode(response.body);

    Dio dio = Dio();
    List<Future<dynamic>> downloading = [];
    for (Map<String, dynamic> s in jsonBody) {
      if (s['id'] == null || s['platform'] == null || s['url'] == null) continue;
      downloading.add(
        dio.download(s['url'], '${path.path}/${pl.listId}/${s["id"]}.${oldPlatform.codec}')
      );
    }

    // song imgs
    for (Song s in pl.songs) {
      String fileExt = s.imgUrl.split('.').last;
      String downloadPath = '${path.path}/${pl.listId}/${s.platformId}.$fileExt';
      downloading.add(dio.download(s.imgUrl, downloadPath));
      s.imgUrl = downloadPath;
      s.isDownloaded = true;
    }

    // playlist img
    String fileExt = pl.imgUrl.split('.').last;
    String downloadPath = '${path.path}/${pl.listId}/${pl.listId}.$fileExt';
    downloading.add(dio.download(pl.imgUrl, downloadPath));
    pl.imgUrl = downloadPath;

    await Future.wait(downloading);

    return pl;
  }

  downloadSong(Directory path, Playlist pl, Song song) async {
    final Uri url = Uri.http(
      serverUrl,
      '/api/stream',
    );

    List<Map<String, dynamic>> body = [
      {
        'platform': song.platform.id,
        'id': song.platformId,
        'codec': song.platform.codec,
      },
    ];

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    final jsonBody = json.decode(response.body);

    Dio dio = Dio();
    List<Future<dynamic>> downloading = [];

    for (Map<String, dynamic> s in jsonBody) {
      if (s['id'] == null || s['platform'] == null || s['url'] == null) continue;
      downloading.add(
        dio.download(s['url'], '${path.path}/${pl.listId}/${s["id"]}.${song.platform.codec}')
      );
    }

    // song img
    String fileExt = song.imgUrl.split('.').last;
    String downloadPath = '${path.path}/${pl.listId}/${song.platformId}.$fileExt';
    downloading.add(dio.download(song.imgUrl, downloadPath));
    song.imgUrl = downloadPath;
    song.isDownloaded = true;

    await Future.wait(downloading);

    return pl;
  }

  search(String query, int limit, UserData user) async {
    final Uri url = Uri.http(
      serverUrl,
      '/api/search',
      {
        'q': query,
        'limit': limit.toString(),
        'sp_token': user.spotifyAccount.accessToken,
        'platforms': '1,2,3'
      },
    );

    final response = await http.get(url);
    final jsonBody = json.decode(response.body);

    Map<String, List<Song>> results = {
      '1': [],
      '2': [],
      '3': [],
    };

    results['1']?.addAll(jsonBody['1'].map<Song>((s) => Song.fromJson(s, AudioPlatform.youtube(), Playlist.empty(), parseDuration: false)));
    results['2']?.addAll(jsonBody['2'].map<Song>((s) => Song.fromJson(s, AudioPlatform.spotify(), Playlist.empty())));
    results['3']?.addAll(jsonBody['3'].map<Song>((s) => Song.fromJson(s, AudioPlatform.soundcloud(), Playlist.empty())));

    return results;
  }
}
