import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:medley/objects/song.dart';
import 'package:medley/objects/playlist.dart';

class CurrentlyPlaying with ChangeNotifier {
  bool _display = false;
  bool _isPlaying = false;
  bool _shuffle = false;
  bool _loop = false;
  double _volume = 1;
  Duration _progress = Duration.zero;

  Song _song = Song.empty();
  Playlist _playlist = Playlist.empty();

  final AudioPlayer _player = AudioPlayer();
  final Random _rng = Random();

  List<Song> _queue = [];
  int _queueIndex = -1;
  int _nextIndex = -1;
  String _currentUrl = '';
  String _cachedUrl = '';

  bool get display => _display;
  bool get isPlaying => _isPlaying;
  bool get shuffle => _shuffle;
  bool get loop => _loop;
  double get volume => _volume;
  Song get song => _song;
  Playlist get playlist => _playlist;
  AudioPlayer get player => _player;

  void setSong() {}

  void playSong() async {
    _display = true;
    _isPlaying = true;
    _song = _queue[_nextIndex];
    _queueIndex = _nextIndex;

    if (_player.state == PlayerState.playing) _player.stop();

    if (_cachedUrl == '') {
      if (_currentUrl == '') _currentUrl = await _song.url;
      _player.play(UrlSource(_currentUrl));
    }
    else {
      _player.play(UrlSource(_cachedUrl));
      _currentUrl = _cachedUrl;
      _cachedUrl = '';
    }

    _cacheNext();

    notifyListeners();
  }

  void setPlaylist(Playlist pl) {
    if (_player.state == PlayerState.playing) _player.stop();

    _playlist = pl;
    _display = true;
    _isPlaying = true;

    _queue = _playlist.songs;
    _queueIndex = -1;
    _nextIndex = -1;
    _cachedUrl = '';
    _currentUrl = '';

    _determineNextIndex();

    playSong();
    notifyListeners();
  }

  void nextSong() {
    if (_queue.isEmpty) return;
    if (_progress.inSeconds < 3) return;

    if (_loop) {
      _cachedUrl = _currentUrl;
      _nextIndex = _queueIndex;
    }

    playSong();
  }

  void prevSong() {
    if (_queue.isEmpty) return;
    if (_progress.inSeconds < 3) return;

    _cachedUrl = _currentUrl;
    _nextIndex = _queueIndex;
    playSong();
  }

  void togglePlaying() async {
    if (_queue.isEmpty) return;

    _isPlaying = !_isPlaying;
    _isPlaying ? _player.resume() : _player.pause();
    notifyListeners();
  }

  void toggleShuffle() async {
    _shuffle = !_shuffle;
    if (_queue.isNotEmpty) _cacheNext();
    notifyListeners();
  }

  void toggleLoop() {
    _loop = !_loop;
    if (_queue.isEmpty) _cacheNext();
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v;
    _player.setVolume(v);
    notifyListeners();
  }

  void setProgress(Duration progress) {
    _progress = progress;
    notifyListeners();
  }

  void _determineNextIndex() {
    if (_shuffle) {
      _nextIndex = _queueIndex;
      while (_nextIndex == _queueIndex) {
        _nextIndex = _rng.nextInt(_queue.length);
      }
      return;
    }

    if (_queueIndex == -1) {
      _nextIndex = 0;
      return;
    }

    if (_queueIndex < _queue.length-1) {
      _nextIndex = _queueIndex + 1;
      return;
    }

    _nextIndex = 0;
  }

  void _cacheNext() async {
    _determineNextIndex();
    _cachedUrl = await _queue[_nextIndex].url;
  }
}
