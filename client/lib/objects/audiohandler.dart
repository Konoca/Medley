import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:medley/providers/song_provider.dart';

class MedleyAudioHandler extends BaseAudioHandler {
  AudioPlayer _player = AudioPlayer();
  CurrentlyPlaying _singleton = CurrentlyPlaying();

  MedleyAudioHandler(this._player, this._singleton);

  @override
  Future<void> play() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> skipToNext() async => _singleton.nextSong();
  @override
  Future<void> skipToPrevious() async => _singleton.prevSong();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  void setPlayer(AudioPlayer player) {
    _player = player;
  }

  void setSingleton(CurrentlyPlaying singleton) {
    _singleton = singleton;
  }
}