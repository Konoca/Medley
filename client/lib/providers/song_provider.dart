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

  List<Song> _queue = [];
  int _queueIndex = 0;
  String _cachedUrl = '';

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

    if (_cachedUrl == '') {
      await _player.setUrl(await _song.url);
    } else {
      await _player.setUrl(_cachedUrl);
    }

    await _player.play();
    notifyListeners();

    if (_queueIndex < _queue.length) {
      _cachedUrl = await _queue[_queueIndex+1].url;
    }
  }

  void setPlaylist(Playlist pl) {
    _player.stop();

    _playlist = pl;
    _display = true;
    _isPlaying = true;

    _queue = _playlist.songs;
    _queueIndex = 0;

    setSong(_queue[_queueIndex]);
    notifyListeners();
  }

  void nextSong() async {
    if (!_loop) _queueIndex++;
    if (_queueIndex >= _queue.length) _queueIndex = 0;
    setSong(_queue[_queueIndex]);
  }

  void togglePlaying() async {
    _isPlaying = !_isPlaying;
    if (!_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    if (_shuffle) _player.shuffle();
    notifyListeners();
  }

  void toggleLoop() {
    _loop = !_loop;
    // if (_loop) _player.setLoopMode(LoopMode.one);
    // else _player.setLoopMode(LoopMode.all);
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v;
    _player.setVolume(v);
    notifyListeners();
  }
}
