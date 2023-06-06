import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:medley/objects/platform.dart';

class MedleyService {
  Future<String> getStreamUrl(Platform platform, String id) async {
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
}
