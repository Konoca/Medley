import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:medley/objects/song.dart';
import 'package:medley/objects/playlist.dart';
import 'package:medley/providers/user_provider.dart';

import '../services/medley.dart';

class CurrentlyPlaying with ChangeNotifier {
  bool _display = false;
  bool _isPlaying = false;
  bool _shuffle = false;
  bool _loop = false;
  double _volume = 1;
  Duration _progress = Duration.zero;

  Song _song = Song.empty();
  Playlist _playlist = Playlist.empty();
  late AllPlaylists _allPlaylists;

  final AudioPlayer _player = AudioPlayer();
  late AudioSession session;
  final Random _rng = Random();

  List<Song> _queue = [];
  final List<int> _queueIdxHistory = [];
  int _queueIndex = -1;
  int _nextIndex = -1;
  SongCache _cache = SongCache();
  bool _isCaching = false;

  bool get display => _display;
  // bool get isPlaying => _player.playing;
  bool get isPlaying => _isPlaying;
  bool get shuffle => _shuffle;
  bool get loop => _loop;
  double get volume => _volume;
  Song get song => _song;
  Playlist get playlist => _playlist;
  AudioPlayer get player => _player;
  SongCache get cache => _cache;
  bool get isCaching => _isCaching;
  AllPlaylists get allPlaylists => _allPlaylists;

  late UserData user;

  CurrentlyPlaying() {
    _cache.fetchFromStorage();
    init();
  }

  init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void playSong({addQueueIndex = true}) async {
    _display = true;
    _isPlaying = true;
    _song = _queue[_nextIndex];
    if (_queueIndex != -1 && addQueueIndex == true) _queueIdxHistory.add(_queueIndex);
    _queueIndex = _nextIndex;

    if (_player.playing) _player.stop();

    String url = _cache.get(_song);

    try {
      if (url == '') throw Exception();
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: _song.title,
            artist: _song.artist,
            artUri: Uri.parse(_song.imgUrl),
            album: _playlist.title,
          ),
        ),
      );
      _setCaching(false);
    } on Exception {
      _setCaching(true);
      _cache = await MedleyService().getStreamUrlBulk(_queue, _cache, token: _song.platform.fetchToken(user));
      url = _cache.get(_song);
      _setCaching(false);
      _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: _song.title,
            artist: _song.artist,
            artUri: Uri.parse(_song.imgUrl),
            album: _playlist.title,
          ),
        ),
      );
    }
    _player.play();

    _determineNextIndex();
    notifyListeners();
  }

  void setPlaylist(Playlist pl, {Song? song}) async {
    if (_player.playing) _player.stop();

    _playlist = pl;
    _display = true;
    _isPlaying = true;

    _queue = _playlist.songs;
    _queueIndex = song != null ? _playlist.findSongIndex(song) : -1;
    _nextIndex = song != null ? _playlist.findSongIndex(song) : -1;

    if (song != null) _determineNextIndex();

    playSong();
    notifyListeners();
  }

  void nextSong() {
    if (_queue.isEmpty) return;

    if (_loop) {
      _nextIndex = _queueIndex;
    }

    playSong();
  }

  void prevSong() {
    if (_queue.isEmpty) return;

    _nextIndex = _queueIndex;
    if (_progress.inSeconds <= 3 && _queueIdxHistory.isNotEmpty) _nextIndex = _queueIdxHistory.removeLast();

    playSong(addQueueIndex: false);
  }

  void togglePlaying() async {
    if (_queue.isEmpty) return;

    _isPlaying = !_isPlaying;
    _isPlaying ? _player.play() : _player.pause();
    notifyListeners();
  }

  void toggleShuffle() async {
    _shuffle = !_shuffle;
    _determineNextIndex();
    notifyListeners();
  }

  void toggleLoop() {
    _loop = !_loop;
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

  void seek(Duration position) {
    _progress = position;
    _player.seek(position);
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

    if (_queueIndex < _queue.length - 1) {
      _nextIndex = _queueIndex + 1;
      return;
    }

    _nextIndex = 0;
    notifyListeners();
  }

  void _setCaching(bool c) {
    _isCaching = c;
    notifyListeners();
  }
}
