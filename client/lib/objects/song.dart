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
            'https://rr5---sn-8xgp1vo-cvnl.googlevideo.com/videoplayback?expire=1685919988&ei=lMR8ZLSxCMCB_9EPnuS3QA&ip=2600%3A4040%3A53fa%3Adb00%3A851a%3A45d1%3A604a%3Aeac1&id=o-ADxemR_RkJxxlWBPBHqjVSZxr2r1ssRUqWijpJwofAMH&itag=251&source=youtube&requiressl=yes&mh=2z&mm=31%2C29&mn=sn-8xgp1vo-cvnl%2Csn-8xgp1vo-ab5e&ms=au%2Crdu&mv=m&mvi=5&pcm2cms=yes&pl=37&gcr=us&initcwndbps=1811250&spc=qEK7B7T0vz5uDW7jc6_RbLb1fjAcInU&vprv=1&svpuc=1&mime=audio%2Fwebm&gir=yes&clen=4177355&dur=232.221&lmt=1634159252367511&mt=1685898045&fvip=8&keepalive=yes&fexp=24007246%2C24363393&c=ANDROID&txp=5532434&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cgcr%2Cspc%2Cvprv%2Csvpuc%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=AOq0QJ8wRQIhAPkOESmwtr9t8vh-smty8lxCOn3k6E3oH0IlGIjVwMCWAiBdPY-i_tawgD15xjtAILkxw6ym3KrLVpOZ22VppTLL4Q%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpcm2cms%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIhAONkibhi6Q7O-mKO0pxmQ8SUI-kP8YX_ehg6mumam2ZZAiBU7Vs2w_pkztZiH3zDVB16CeS8z5eiiGbXDRD2timYnw%3D%3D',
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
