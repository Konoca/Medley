import 'package:medley/objects/platform.dart';

class Song {
  final String title;
  final String artist;
  final String imgUrl;
  final String platformId;
  final AudioPlatform platform;

  Song(
    this.title,
    this.artist,
    this.imgUrl,
    this.platformId,
    this.platform,
  );

  Song.test()
      : title = 'The Owl Song',
        artist = 'The Owls',
        imgUrl =
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
        platformId = 'psuRGfAaju4',
        platform = AudioPlatform.youtube();

  Song.test2()
      : title = 'Owl On a Stick',
        artist = 'The Owls',
        imgUrl =
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
        platformId = 'birocratic/whenyoureable',
        platform = AudioPlatform.soundcloud();

  Song.test3()
      : title = 'Lizard dance',
        artist = 'The lizard',
        imgUrl =
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
        platformId = 'LZsVk-ab0AA',
        platform = AudioPlatform.youtube();

  Song.empty()
      : title = '',
        artist = '',
        imgUrl = '',
        platformId = '',
        platform = AudioPlatform.empty();
}

class SongCache {
  final Map<SongCacheKey, String> _cache = {};

  void set(String id, int platform, String url) {
    final key = SongCacheKey(AudioPlatform.fromId(platform), id);
    _cache[key] = url;
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
}

class SongCacheKey {
  AudioPlatform platform;
  String platformId;

  SongCacheKey(this.platform, this.platformId);

  @override
  bool operator ==(covariant SongCacheKey other) => platform.id == other.platform.id && platformId == other.platformId;

  @override
  int get hashCode => platformId.hashCode + platform.id;
}
