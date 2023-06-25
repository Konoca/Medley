// import 'dart:io';
// import 'package:flutter/foundation.dart';

import 'package:medley/providers/user_provider.dart';

import 'iso8601_duration.dart';

class AudioPlatform {
  final String name;
  final int id;
  final String codec;

  // AudioPlatform(this.name, this.id, this.codec);

  factory AudioPlatform.fromId(id) {
    switch (id.toString()) {
      case '1':
        return AudioPlatform.youtube();
      case '2':
        return AudioPlatform.spotify();
      case '3':
        return AudioPlatform.soundcloud();
      default:
        return AudioPlatform.empty();
    }
  }

  String parseDuration(input) {
    switch (id) {
      case 1:
        return ISO8601Duration(input['duration']).toDuration().toString();
      case 2:
        return Duration(milliseconds: input['duration']).toString();
      default:
        return input['duration'].toString();
    }
  }

  String fetchToken(UserData user) {
    switch (id) {
      case 1:
        return user.youtubeAccount.accessToken;
      case 2:
        return user.spotifyAccount.accessToken;
      default:
        return '';
    }
  }

  AudioPlatform.empty()
      : name = "",
        id = 0,
        codec = "";

  AudioPlatform.youtube()
      : name = "Youtube",
        id = 1,
        codec = "mp4";
        // codec = "m4a";

  AudioPlatform.spotify()
      : name = "Spotify",
        id = 2,
        codec = "mp4";

  AudioPlatform.soundcloud()
      : name = "Soundcloud",
        id = 3,
        codec = "mp3";
}
