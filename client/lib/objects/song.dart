import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medley/objects/platform.dart';

class Song {
  final String title;
  final String artist;
  final String imgUrl;
  final String duration;
  final String platformId;
  final AudioPlatform platform;

  Song(
    this.title,
    this.artist,
    this.imgUrl,
    this.duration,
    this.platformId,
    this.platform,
  );

  factory Song.fromJson(Map<String, dynamic> json, AudioPlatform platform) {
    return Song(
      json['song_title'],
      json['artist'],
      json['thumbnail'],
      platform.parseDuration(json),
      json['song_id'],
      platform,
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
    );
  }

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
      'platform_id': platform.id
    };
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
    _cache = jsonDecode(await _storage.read(key: _storageKey) as String).map<SongCacheKey, String>(
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
