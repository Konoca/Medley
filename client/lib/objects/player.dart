import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:medley/objects/playlist.dart';
import 'package:medley/objects/song.dart';
import 'package:medley/providers/user_provider.dart';
import 'package:medley/services/medley.dart';

class CustomAudioPlayer extends BaseAudioHandler
    with ChangeNotifier, SeekHandler {
  bool _isPlaying = false;
  bool _shuffle = false;
  bool _loop = false;
  double _volume = 1;
  Duration _progress = Duration.zero;

  Song _song = Song.empty();
  Playlist _playlist = Playlist.empty();

  final AudioPlayer _player = AudioPlayer();
  late AudioSession session;

  final Random _rng = Random();

  List<Song> _queue = [];
  final List<int> _queueIdxHistory = [];
  int _queueIndex = -1;
  int _nextIndex = -1;
  SongCache _cache = SongCache();
  bool _isCaching = false;

  late UserData user;

  bool get isPlaying => _isPlaying;
  bool get shuffle => _shuffle;
  bool get loop => _loop;
  double get volume => _volume;
  Song get song => _song;
  Playlist get playlist => _playlist;
  AudioPlayer get player => _player;
  SongCache get cache => _cache;
  bool get isCaching => _isCaching;

  CustomAudioPlayer() {
    _cache.fetchFromStorage();
  }

  @override
  play() async {
    _isPlaying = true;
    return _player.play();
  }

  @override
  pause() async {
    _isPlaying = false;
    return _player.pause();
  }

  @override
  stop() async {
    _isPlaying = false;
    return _player.pause();
  }

  @override
  skipToNext() {
    return nextSong();
  }

  @override
  skipToPrevious() {
    return prevSong();
  }

  @override
  seek(Duration position) {
    _progress = position;
    playbackState.add(
      playbackState.value.copyWith(
        updatePosition: position,
      ),
    );
    notifyListeners();
    return _player.seek(position);
  }

  @override
  playMediaItem(MediaItem mediaItem) async {
    await _player.setAudioSource(AudioSource.uri(Uri.parse(mediaItem.id)));
    super.mediaItem.add(mediaItem);
    play();
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.skipToNext,
        MediaControl.pause,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.play,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.ready,
      playing: true,
    ));
  }

  void playSong({addQueueIndex = true}) async {
    _isPlaying = true;
    _song = _queue[_nextIndex];

    if (_queueIndex != -1 && addQueueIndex == true) {
      _queueIdxHistory.add(_queueIndex);
    }
    _queueIndex = _nextIndex;

    if (_player.playing) _player.stop();

    String url = _cache.get(_song);

    try {
      if (url == '') throw Exception();
      await playMediaItem(MediaItem(
        id: url,
        title: _song.title,
        artist: _song.artist,
        artUri: Uri.parse(_song.imgUrl),
        album: _playlist.title,
        duration: _song.toDuration(),
      ));
      _setCaching(false);
    } on Exception {
      _setCaching(true);
      _cache = await MedleyService().getStreamUrlBulk(
        _queue,
        _cache,
        token: _song.platform.fetchToken(user),
      );
      url = _cache.get(_song);
      _setCaching(false);

      playMediaItem(MediaItem(
        id: url,
        title: _song.title,
        artist: _song.artist,
        artUri: Uri.parse(_song.imgUrl),
        album: _playlist.title,
        duration: _song.toDuration(),
      ));
    }

    _determineNextIndex();
    notifyListeners();
  }

  void setPlaylist(Playlist pl, {Song? song}) async {
    if (_player.playing) _player.stop();

    _playlist = pl;
    _isPlaying = true;

    _queue = _playlist.songs;
    _queueIndex = song != null ? _playlist.findSongIndex(song) : -1;
    _nextIndex = song != null ? _playlist.findSongIndex(song) : -1;

    if (song != null) _determineNextIndex();

    playSong();
    notifyListeners();
  }

  Future<void> nextSong() async {
    if (_queue.isEmpty) return;

    if (_loop) {
      _nextIndex = _queueIndex;
    }

    playSong();
  }

  Future<void> prevSong() async {
    if (_queue.isEmpty) return;

    _nextIndex = _queueIndex;
    if (_progress.inSeconds <= 3 && _queueIdxHistory.isNotEmpty) {
      _nextIndex = _queueIdxHistory.removeLast();
    }

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
