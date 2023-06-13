import 'package:medley/objects/platform.dart';
import 'package:medley/objects/song.dart';

class Playlist {
  final String title;
  final AudioPlatform platform;
  final String listId;
  final String imgUrl;
  final int numberOfTracks;
  List<Song> songs;

  Playlist(
    this.title,
    this.platform,
    this.listId,
    this.imgUrl,
    this.numberOfTracks,
    this.songs,
  );

  factory Playlist.fromJsonWithSongs(Map<String, dynamic> json) {
    AudioPlatform platform = AudioPlatform.fromId(json['platform']);
    List<Song> songs = json['songs'].map<Song>((s) => Song.fromJson(s, platform)).toList();
    return Playlist(
      json['playlist_name'],
      platform,
      json['playlist_id'],
      json['thumbnail'], // TODO image url
      songs.length,
      songs,
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    AudioPlatform platform = AudioPlatform.fromId(json['platform']);
    return Playlist(
      json['playlist_name'],
      platform,
      json['playlist_id'],
      json['thumbnail'], // TODO image url
      json['songs'],
      [],
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
}

class AllPlaylists {
  List<Playlist> custom = [];
  List<Playlist> youtube = [];
  List<Playlist> spotify = [];
  List<Playlist> soundcloud = [];

  AllPlaylists(this.custom, this.youtube, this.spotify, this.soundcloud);

  void updatePlaylistSongs(Playlist playlist) {
    switch (playlist.platform.id) {
      case 1:
        youtube.where((pl) => playlist.listId == pl.listId).first.songs = playlist.songs;
        break;
      case 2:
        break;
      case 3:
        break;
      default:
    }
  }

  bool isEmpty() {
    return (custom.isEmpty && youtube.isEmpty && spotify.isEmpty && soundcloud.isEmpty);
  }
}
