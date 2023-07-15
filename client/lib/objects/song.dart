import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medley/objects/platform.dart';
import 'package:medley/objects/playlist.dart';

class Song {
  final String title;
  final String artist;
  String imgUrl;
  final String duration;
  final String platformId;
  final AudioPlatform platform;
  bool isDownloaded = false;

  Song(
    this.title,
    this.artist,
    this.imgUrl,
    this.duration,
    this.platformId,
    this.platform,
    [
      this.isDownloaded = false,
    ]
  );

  factory Song.fromJson(
    Map<String, dynamic> json,
    AudioPlatform platform,
    Playlist pl,
    {
      parseDuration = true,
    }
  ) {
    return Song(
      json['song_title'],
      json['artist'],
      json['thumbnail'] != '' ? json['thumbnail'] : pl.imgUrl,
      parseDuration ? platform.parseDuration(json) : json['duration'] + ':000000',
      json['song_id'],
      platform,
      json['is_downloaded'] ?? false,
    );
  }

  factory Song.fromStorageMap(Map<String, dynamic> map) {
    return Song(
      map['song_title'],
      map['artist'],
      map['thumbnail'],
      map['duration'] ?? '',
      map['song_id'],
      AudioPlatform.fromId(map['platform_id']),
      map['is_downloaded'],
    );
  }

  Song.copy(Song s)
      : title = s.title,
        artist = s.artist,
        imgUrl = s.imgUrl,
        duration = s.duration,
        platformId = s.platformId,
        platform = s.platform;

  Song.empty()
      : title = '',
        artist = '',
        imgUrl = '',
        duration = '',
        platformId = '',
        platform = AudioPlatform.empty();

  Map<String, dynamic> toStorageMap() {
    return {
      'song_title': title,
      'artist': artist,
      'thumbnail': imgUrl,
      'duration': duration,
      'song_id': platformId,
      'platform_id': platform.id,
      'is_downloaded': isDownloaded,
    };
  }

  Duration toDuration() {
    List<String> parts = duration.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    List<String> secondsParts = parts[2].split('.');
    int seconds = int.parse(secondsParts[0]);
    // int milliseconds = int.parse(secondsParts[1]);

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds + 1,
      // milliseconds: milliseconds,
    );
  }
}

class SongCache {
  Map<SongCacheKey, String> _cache = {};
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _storageKey = 'medley_cache_songs';

  void set(String id, int platform, String url) {
    final key = SongCacheKey(AudioPlatform.fromId(platform), id);
    _cache[key] = url;
    save();
  }

  String get(Song song) {
    final key = SongCacheKey(song.platform, song.platformId);
    return _cache.containsKey(key) ? _cache[key]! : '';
  }

  void remove(Song song) {
    final key = SongCacheKey(song.platform, song.platformId);
    if (_cache.containsKey(key)) _cache.remove(key);
  }

  bool contains(Song song) {
    final key = SongCacheKey(song.platform, song.platformId);
    return _cache.containsKey(key);
  }

  bool isEmpty() {
    return _cache.isEmpty;
  }

  void clear() {
    _cache = {};
    save();
  }

  void save() {
    _storage.write(
      key: _storageKey,
      value: jsonEncode(
        _cache.map(
          (key, value) => MapEntry(
            key.toString(),
            value,
          ),
        ),
      ),
    );
  }

  fetchFromStorage() async {
    if (!await _storage.containsKey(key: _storageKey)) return;
    _cache = jsonDecode(await _storage.read(key: _storageKey) as String)
        .map<SongCacheKey, String>(
      (String key, dynamic value) => MapEntry(
        SongCacheKey.fromString(key),
        value.toString(),
      ),
    );
    return _cache;
  }
}

class SongCacheKey {
  AudioPlatform platform;
  String platformId;

  SongCacheKey(this.platform, this.platformId);

  factory SongCacheKey.fromString(String s) {
    return SongCacheKey(AudioPlatform.fromId(s[0]), s.substring(1));
  }

  @override
  String toString() {
    return '${platform.id}$platformId';
  }

  @override
  bool operator ==(covariant SongCacheKey other) =>
      platform.id == other.platform.id && platformId == other.platformId;

  @override
  int get hashCode => '${platform.id} -> $platformId'.hashCode;
}
