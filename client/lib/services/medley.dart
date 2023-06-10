import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:medley/objects/platform.dart';

import '../objects/song.dart';

class MedleyService {
  Future<String> getStreamUrl(AudioPlatform platform, String id) async {
    var url = Uri.http(
      dotenv.env['SERVER_URL']!,
      '/stream',
      {
        'platform': platform.id.toString(),
        'id': id.toString(),
        'codec': platform.codec.toString(),
      },
    );
    var response = await http.get(url);
    String streamUrl = (jsonDecode(response.body) as Map)['url'];
    return streamUrl;
  }

  Future<SongCache> getStreamUrlBulk(List<Song> songs, SongCache cache) async {
    final Uri url = Uri.http(
      dotenv.env['SERVER_URL']!,
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
}
