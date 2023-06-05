import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medley/objects/song.dart';
import 'package:medley/objects/playlist.dart';

class CurrentlyPlaying with ChangeNotifier {
  bool _display = false;
  bool _isPlaying = false;
  bool _shuffle = false;
  bool _loop = false;
  double _volume = 1;


  Song _song = Song.empty();
  Playlist _playlist = Playlist.empty();

  final AudioPlayer _player = AudioPlayer();

  bool get display => _display;
  bool get isPlaying => _isPlaying;
  bool get shuffle => _shuffle;
  bool get loop => _loop;
  double get volume => _volume;
  Song get song => _song;
  Playlist get playlist => _playlist;
  AudioPlayer get player => _player;

  void setSong(Song song) async {
    _display = true;
    _isPlaying = true;
    _song = song;
    await _player.setUrl(_song.url);
    await _player.play();
    notifyListeners();
  }

  void setPlaylist(Playlist pl) {
    _playlist = pl;
    setSong(_playlist.songs[0]);
    notifyListeners();
  }

  void togglePlaying() {
    _isPlaying = !_isPlaying;
    togglePlayer();
    notifyListeners();
  }
  
  void togglePlayer() async {
    if (!_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleLoop() {
    _loop = !_loop;
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v;
    notifyListeners();
  }
}