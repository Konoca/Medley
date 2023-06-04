import 'package:medley/objects/song.dart';

class Playlist {
  final String title;
  final String platform;
  final int id;
  final int numberOfTracks;
  final List<Song> songs;

  Playlist(this.title, this.platform, this.id, this.numberOfTracks, this.songs);

  Playlist.test()
      : title = 'Favorites',
        platform = '',
        id = 1,
        numberOfTracks = 1,
        songs = [Song.test()];

  Playlist.test2()
      : title = 'Liked Songs',
        platform = '',
        id = 2,
        numberOfTracks = 1,
        songs = [Song.test2()];

  Playlist.empty()
      : title = '',
        platform = '',
        id = 0,
        numberOfTracks = 0,
        songs = [];
}
