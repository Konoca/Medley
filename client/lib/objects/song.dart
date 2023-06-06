import 'package:medley/objects/platform.dart';
import 'package:medley/services/medley.dart';

class Song {
  final String title;
  final String artist;
  final String imgUrl;
  final int duration;
  final String platformId;
  final Platform platform;

  Song(
    this.title,
    this.artist,
    this.imgUrl,
    this.duration,
    this.platformId,
    this.platform,
  );

  Future<String> get url async => await MedleyService().getStreamUrl(platform, platformId);

  Song.test()
      : title = 'The Owl Song',
        artist = 'The Owls',
        imgUrl =
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
        duration = 300,
        platformId = 'psuRGfAaju4',
        platform = Platform.youtube();

  Song.test2()
      : title = 'Owl On a Stick',
        artist = 'The Owls',
        imgUrl =
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
        duration = 169,
        platformId = 'birocratic/whenyoureable',
        platform = Platform.soundcloud();

  Song.test3()
      : title = 'Lizard dance',
        artist = 'The lizard',
        imgUrl = 
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
        duration = 19,
        platformId = 'LZsVk-ab0AA',
        platform = Platform.youtube();

  Song.empty()
      : title = '',
        artist = '',
        imgUrl = '',
        duration = 0,
        platformId = '',
        platform = Platform.empty();
}
