import 'package:medley/objects/platform.dart';
import 'package:medley/services/medley.dart';

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

  Future<String> get url async => await MedleyService().getStreamUrl(platform, platformId);

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
