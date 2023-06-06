import 'package:medley/objects/platform.dart';
import 'package:medley/objects/song.dart';

class Playlist {
  final String title;
  final Platform platform;
  final int id;
  final String listId;
  final int numberOfTracks;
  final List<Song> songs;

  Playlist(
    this.title,
    this.platform,
    this.id,
    this.listId,
    this.numberOfTracks,
    this.songs,
  );

  Playlist.test()
      : title = 'Favorites',
        platform = Platform.empty(),
        id = 1,
        listId = '',
        numberOfTracks = 2,
        songs = [
          Song.test(),
          Song.test2(),
        ];

  Playlist.test2()
      : title = 'Liked Songs',
        platform = Platform.soundcloud(),
        id = 2,
        listId = '',
        numberOfTracks = 1,
        songs = [
          Song.test2(),
        ];

  Playlist.test3()
      : title = 'Test',
        platform = Platform.soundcloud(),
        id = 3,
        listId = '',
        numberOfTracks = 2,
        songs = [
          Song.test3(),
          Song.test2(),
        ];

  Playlist.test4()
      : title = 'Test',
        platform = Platform.soundcloud(),
        id = 3,
        listId = '',
        numberOfTracks = 2,
        songs = [
          Song.test3(),
          Song.test3(),
        ];
  
  Playlist.test5()
      : title = 'Test',
        platform = Platform.soundcloud(),
        id = 3,
        listId = '',
        numberOfTracks = 3,
        songs = [
          Song.test(),
          Song.test2(),
          Song.test3(),
        ];

  Playlist.empty()
      : title = '',
        platform = Platform.empty(),
        id = 0,
        listId = '',
        numberOfTracks = 0,
        songs = [];
}

class AllPlaylists {
  List<Playlist> custom = [];
  List<Playlist> youtube = [];
  List<Playlist> spotify = [];
  List<Playlist> soundcloud = [];

  AllPlaylists(this.custom, this.youtube, this.spotify, this.soundcloud);

  AllPlaylists.fetch() {
    // TODO fetch playlist data
    custom = [
      Playlist.test(),
      Playlist.test2(),
      Playlist.test3(),
      Playlist.test4(),
      Playlist.test5(),
    ];
    youtube = [
      Playlist.test(),
      Playlist.test2(),
      Playlist.test(),
      Playlist.test2(),
    ];
    spotify = [
      // Playlist.test(),
      // Playlist.test2(),
      // Playlist.test(),
      // Playlist.test2(),
      // Playlist.test(),
      // Playlist.test2(),
    ];
    soundcloud = [
      Playlist.test(),
      Playlist.test2(),
      Playlist.test(),
      Playlist.test2(),
      Playlist.test(),
      Playlist.test2(),
      Playlist.test(),
      Playlist.test2(),
    ];
  }
}
