class Song {
  final String title;
  final String artist;
  final String imgUrl;
  final int duration;
  final String url;
  final String platform;

  Song(this.title, this.artist, this.imgUrl, this.duration, this.url,
      this.platform);

  Song.test()
      : title = 'The Owl Song',
        artist = 'The Owls',
        imgUrl =
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
        duration = 300,
        url =
            'https://rr5---sn-8xgp1vo-cvnl.googlevideo.com/videoplayback?expire=1685947387&ei=my99ZKqxNYq98wTS6bCIDw&ip=2600%3A4040%3A53fa%3Adb00%3A851a%3A45d1%3A604a%3Aeac1&id=o-AITG2_Z8phzaqbIE5hOg0NcwJoyvquUiuj6Xex3J2icd&itag=22&source=youtube&requiressl=yes&mh=2z&mm=31%2C29&mn=sn-8xgp1vo-cvnl%2Csn-8xgp1vo-ab5e&ms=au%2Crdu&mv=m&mvi=5&pl=37&gcr=us&initcwndbps=1545000&spc=qEK7B2kXgoS94GazyWSDeuceApyJ4gs&vprv=1&svpuc=1&mime=video%2Fmp4&cnr=14&ratebypass=yes&dur=232.245&lmt=1674147215044971&mt=1685924921&fvip=8&fexp=24007246%2C24362685%2C51000023&beids=24350018&c=ANDROID&txp=5532434&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cgcr%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Ccnr%2Cratebypass%2Cdur%2Clmt&sig=AOq0QJ8wRAIgeLdx1de2hxmxQ8LZ0DolzqlpAL9Mii1tAIQTXCHm6cACICsvNYtLOLH-1gVuUIhBLVkReU8_q3vsDey_ZoDaLYit&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIgfVjsnBVVCkobb8IRHZSTyXieNbtnk43YpT6nodtkdagCIQCcGEK21R4AaUvleqZXIXCDoE4IN3MbQHgYxlpLnpCP7A%3D%3D',
        platform = 'Youtube';

  Song.test2()
      : title = 'Owl On a Stick',
        artist = 'The Owls',
        imgUrl =
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
        duration = 169,
        url = 'smth',
        platform = 'Spotify';

  Song.empty()
      : title = '',
        artist = '',
        imgUrl = '',
        duration = 0,
        url = '',
        platform = '';
}
