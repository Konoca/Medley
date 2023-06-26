import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medley/objects/platform.dart';
import 'package:medley/objects/playlist.dart';

import 'package:medley/objects/user.dart';
import 'package:medley/services/google_auth.dart';
import 'package:medley/services/medley.dart';
import 'package:medley/services/spotify_auth.dart';

class UserData with ChangeNotifier {
  bool _isAuthenticated = false;
  AllPlaylists _allPlaylists = AllPlaylists([], [], [], []);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserAccount _user = UserAccount.blank();
  YoutubeAccount _yt = YoutubeAccount.blank();
  SpotifyAccount _sp = SpotifyAccount.blank();
  final SoundcloudAccount _sc = SoundcloudAccount.blank();

  bool get isAuthenticated => _isAuthenticated;
  AllPlaylists get allPlaylists => _allPlaylists;
  UserAccount get user => _user;
  YoutubeAccount get youtubeAccount => _yt;
  SpotifyAccount get spotifyAccount => _sp;
  SoundcloudAccount get soundcloudAccount => _sc;

  set user(UserAccount user) => _user;

  String getToken(AudioPlatform platform) {
    switch (platform.id) {
      case 1:
        return _yt.accessToken;
      case 2:
        return _sp.accessToken;
      default:
        return '';
    }
  }

  Future<bool> login() async {
    _user = UserAccount(1, true, '');
    _isAuthenticated = _user.isAuthenticated;
    fetchUsersFromStorage();
    fetchPlaylistsFromStorage();
    return _isAuthenticated;
  }

  Future<bool> loginYoutube() async {
    _yt = await GoogleAuthService().signInToGoogle();
    _storage.write(key: _yt.storageKey, value: _yt.refreshToken);
    fetchPlaylists();
    notifyListeners();
    return _yt.isAuthenticated;
  }

  Future<bool> logoutYoutube(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Are you sure'),
            content: const Text(
                'Are you sure you want to log out of your youtube account?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Yes'),
                onPressed: () {
                  _yt = YoutubeAccount.blank();
                  _storage.delete(key: _yt.storageKey);
                  fetchPlaylists();
                  notifyListeners();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });

    return _yt.isAuthenticated;
  }

  Future<bool> loginSpotify(BuildContext context) async {
    _sp = await SpotifyAuthService().signIn(context);
    _storage.write(
        key: _sp.storageKey, value: "${_sp.refreshToken}/${_sp.accessToken}");
    fetchPlaylists();
    notifyListeners();
    return _sp.isAuthenticated;
  }

  Future<bool> logoutSpotify(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Are you sure'),
            content: const Text(
                'Are you sure you want to log out of your spotify account?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Yes'),
                onPressed: () {
                  _sp = SpotifyAccount.blank();
                  _storage.delete(key: _sp.storageKey);
                  fetchPlaylists();
                  notifyListeners();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });

    return _sp.isAuthenticated;
  }

  Future<bool> loginSoundcloud(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Logging into Soundcloud is currently unavailable.'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });

    notifyListeners();
    return false;
  }

  Future<AllPlaylists> fetchPlaylists() async {
    _allPlaylists.youtube =
        await MedleyService().getYoutubePlaylists(this, scope: 'all');
    _allPlaylists.spotify = await MedleyService().getSpotifyPlaylists(this);
    _allPlaylists.save();
    notifyListeners();
    return _allPlaylists;
  }

  void fetchPlaylistsFromStorage() async {
    _allPlaylists = await _allPlaylists.fetchFromStorage();
    notifyListeners();
  }

  void fetchUsersFromStorage() async {
    if (await _storage.containsKey(key: _yt.storageKey)) {
      _yt = await GoogleAuthService().getAccountFromRefreshToken(
          await _storage.read(key: _yt.storageKey) as String);
    }
    if (await _storage.containsKey(key: _sp.storageKey)) {
      _sp = await SpotifyAuthService().clientFromStorage(
          await _storage.read(key: _sp.storageKey) as String);
      _storage.write(
        key: _sp.storageKey,
        value: "${_sp.refreshToken}/${_sp.accessToken}",
      );
    }
    notifyListeners();
  }

  void updatePlaylist(Playlist playlist) async {
    String token = getToken(playlist.platform);
    playlist = await MedleyService().getSongs(token, playlist);
    _allPlaylists.updatePlaylistSongs(playlist);
    _allPlaylists.save();
    notifyListeners();
  }
}
