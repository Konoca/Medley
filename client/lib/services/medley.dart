import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:medley/objects/platform.dart';
import 'package:medley/objects/playlist.dart';
import 'package:medley/objects/song.dart';
import 'package:medley/providers/user_provider.dart';

final String serverUrl = dotenv.env['SERVER_URL']!;

class MedleyService {
  Future<SongCache> getStreamUrlBulk(List<Song> songs, SongCache cache) async {
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
      cache.set(s['id'], s['platform'], s['url']);
    }

    return cache;
  }

  _getPlaylists(
      String accessToken, AudioPlatform platform, String scope) async {
    final Uri url = Uri.http(
      serverUrl,
      '/api/get_playlists',
      {
        'platform': platform.id.toString(),
        'token': accessToken,
        'scope': scope,
      },
    );

    final response = await http.get(url);

    List<Playlist> playlists = [];
    for (Map<String, dynamic> pl in json.decode(response.body)) {
      playlists.add(Playlist.fromJson(pl));
    }

    return playlists;
  }

  Future<List<Playlist>> getYoutubePlaylists(UserData user, {scope = ''}) async {
    if (!user.youtubeAccount.isAuthenticated) return [];
    return await _getPlaylists(
      user.youtubeAccount.accessToken,
      AudioPlatform.youtube(),
      scope,
    );
  }
}
