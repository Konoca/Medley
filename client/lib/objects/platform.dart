// import 'dart:io';
// import 'package:flutter/foundation.dart';

class AudioPlatform {
  final String name;
  final int id;
  final String codec;

  AudioPlatform(this.name, this.id, this.codec);

  AudioPlatform.empty()
      : name = "",
        id = 0,
        codec = "";

  AudioPlatform.youtube()
      : name = "Youtube",
        id = 1,
        codec = "m4a";

  AudioPlatform.spotify()
      : name = "Spotify",
        id = 2,
        codec = "mp3";

  AudioPlatform.soundcloud()
      : name = "Soundcloud",
        id = 3,
        codec = "mp3";
}
