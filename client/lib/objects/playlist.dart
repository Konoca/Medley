import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medley/objects/platform.dart';
import 'package:medley/objects/song.dart';

const String customStorageKey = 'medley_playtlists_custom';
const String youtubeStorageKey = 'medley_playtlists_youtube';
const String spotifyStorageKey = 'medley_playtlists_spotify';
const String soundcloudStorageKey = 'medley_playtlists_soundcloud';

class Playlist {
  String title;
  AudioPlatform platform;
  final String listId;
  String imgUrl;
  final int numberOfTracks;
  List<Song> songs;
  bool isDownloaded = false;

  Playlist(
    this.title,
    this.platform,
    this.listId,
    this.imgUrl,
    this.numberOfTracks,
    this.songs,
    [
      this.isDownloaded = false,
    ]
  );

  factory Playlist.fromJsonWithSongs(Map<String, dynamic> json) {
    AudioPlatform platform = AudioPlatform.fromId(json['platform']);
    Playlist temp = Playlist(json['playlist_name'], platform,
        json['playlist_id'], json['thumbnail'], 0, []);
    List<Song> songs = json['songs']
        .map<Song>((s) => Song.fromJson(s, platform, temp))
        .toList();
    return Playlist(
      json['playlist_name'],
      platform,
      json['playlist_id'],
      json['thumbnail'],
      songs.length,
      songs,
      json['is_downloaded'],
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    AudioPlatform platform = AudioPlatform.fromId(json['platform']);
    return Playlist(
      json['playlist_name'],
      platform,
      json['playlist_id'],
      json['thumbnail'],
      json['songs'],
      [],
      json['is_downloaded'] ?? false,
    );
  }

  factory Playlist.fromStorageMap(Map<String, dynamic> map) {
    return Playlist(
        map['playlist_name'],
        AudioPlatform.fromId(map['platform_id']),
        map['playlist_id'],
        map['thumbnail'],
        map['number_of_songs'],
        map['songs'].map<Song>((s) => Song.fromStorageMap(s)).toList(),
        map['is_downloaded'],
    );
  }

  Playlist.empty()
      : title = '',
        platform = AudioPlatform.empty(),
        listId = '',
        imgUrl = '',
        numberOfTracks = 0,
        songs = [];

  int findSongIndex(Song song) {
    return songs.indexOf(song) - 1;
  }

  Map<String, dynamic> toStorageMap() {
    return {
      'playlist_name': title,
      'platform_id': platform.id,
      'playlist_id': listId,
      'thumbnail': imgUrl,
      'number_of_songs': numberOfTracks,
      'songs': songs.map((song) => song.toStorageMap()).toList(),
      'is_downloaded': isDownloaded,
    };
  }
}

class AllPlaylists {
  List<Playlist> custom = [];
  List<Playlist> youtube = [];
  List<Playlist> spotify = [];
  List<Playlist> soundcloud = [];

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AllPlaylists(this.custom, this.youtube, this.spotify, this.soundcloud);

  fetchFromStorage() async {
    if (await _storage.containsKey(key: customStorageKey)) {
      custom = jsonDecode(await _storage.read(key: customStorageKey) as String)
          .map<Playlist>((pl) => Playlist.fromStorageMap(pl))
          .toList();
    }
    if (await _storage.containsKey(key: youtubeStorageKey)) {
      youtube =
          jsonDecode(await _storage.read(key: youtubeStorageKey) as String)
              .map<Playlist>((pl) => Playlist.fromStorageMap(pl))
              .toList();
    }
    if (await _storage.containsKey(key: spotifyStorageKey)) {
      spotify =
          jsonDecode(await _storage.read(key: spotifyStorageKey) as String)
              .map<Playlist>((pl) => Playlist.fromStorageMap(pl))
              .toList();
    }
    if (await _storage.containsKey(key: soundcloudStorageKey)) {
      soundcloud =
          jsonDecode(await _storage.read(key: soundcloudStorageKey) as String)
              .map<Playlist>((pl) => Playlist.fromStorageMap(pl))
              .toList();
    }
    return this;
  }

  void updatePlaylistSongs(Playlist playlist) {
    switch (playlist.platform.id) {
      case 1:
        youtube.where((pl) => playlist.listId == pl.listId).first.songs =
            playlist.songs;
        break;
      case 2:
        spotify.where((pl) => playlist.listId == pl.listId).first.songs =
            playlist.songs;
        break;
      case 3:
        soundcloud.where((pl) => playlist.listId == pl.listId).first.songs =
            playlist.songs;
        break;
      default:
    }
  }

  bool isEmpty() {
    return (custom.isEmpty &&
        youtube.isEmpty &&
        spotify.isEmpty &&
        soundcloud.isEmpty);
  }

  void save() {
    _storage.delete(key: customStorageKey);
    _storage.write(
        key: customStorageKey,
        value: jsonEncode(custom.map((pl) => pl.toStorageMap()).toList()));

    _storage.delete(key: youtubeStorageKey);
    _storage.write(
        key: youtubeStorageKey,
        value: jsonEncode(youtube.map((pl) => pl.toStorageMap()).toList()));

    _storage.delete(key: spotifyStorageKey);
    _storage.write(
        key: spotifyStorageKey,
        value: jsonEncode(spotify.map((pl) => pl.toStorageMap()).toList()));

    _storage.delete(key: soundcloudStorageKey);
    _storage.write(
        key: soundcloudStorageKey,
        value: jsonEncode(soundcloud.map((pl) => pl.toStorageMap()).toList()));
  }
}
