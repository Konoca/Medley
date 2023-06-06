class Platform {
  final String name;
  final int id;
  final String codec;

  Platform(this.name, this.id, this.codec);

  Platform.empty()
      : name = "",
        id = 0,
        codec = "";

  Platform.youtube()
      : name = "Youtube",
        id = 1,
        codec = "mp4";

  Platform.spotify()
      : name = "Spotify",
        id = 2,
        codec = "mp3";

  Platform.soundcloud()
      : name = "Soundcloud",
        id = 3,
        codec = "mp3";
}
