import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medley/objects/player.dart';
import 'package:medley/objects/song.dart';
import 'package:medley/objects/playlist.dart';
import 'package:medley/providers/user_provider.dart';

class CurrentlyPlaying with ChangeNotifier {
  bool _display = false;
  late AllPlaylists _allPlaylists;

  late CustomAudioPlayer _handler;
  CustomAudioPlayer get handler => _handler;
  late AudioSession session;

  bool get display => _display;
  bool get isPlaying => _handler.isPlaying;
  bool get shuffle => _handler.shuffle;
  bool get loop => _handler.loop;
  double get volume => _handler.volume;
  Song get song => _handler.song;
  Playlist get playlist => _handler.playlist;
  AudioPlayer get player => _handler.player;
  SongCache get cache => _handler.cache;
  bool get isCaching => _handler.isCaching;

  AllPlaylists get allPlaylists => _allPlaylists;


  CurrentlyPlaying(CustomAudioPlayer handler) {
    _handler = handler;
    init();
  }

  init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void playSong({addQueueIndex = true}) async {
    _display = true;
    _handler.playSong(addQueueIndex: addQueueIndex);
    notifyListeners();
  }

  void setPlaylist(Playlist pl, {Song? song}) async {
    _display = true;
    if (song != null) {
      _handler.setPlaylist(pl, song: song);
      return;
    }

    _handler.setPlaylist(pl);
    notifyListeners();
  }

  void nextSong() {
    _handler.nextSong();
    notifyListeners();
  }

  void prevSong() {
    _handler.prevSong();
    notifyListeners();
  }

  void togglePlaying() async {
    _handler.togglePlaying();
    notifyListeners();
  }

  void toggleShuffle() async {
    _handler.toggleShuffle();
    notifyListeners();
  }

  void toggleLoop() {
    _handler.toggleLoop();
    notifyListeners();
  }

  void setVolume(double v) {
    _handler.setVolume(v);
    notifyListeners();
  }

  void setProgress(Duration progress) {
    _handler.setProgress(progress);
    notifyListeners();
  }

  void seek(Duration position) {
    _handler.seek(position);
    notifyListeners();
  }

  void setUser(UserData user) {
    _handler.user = user;
  }
}
