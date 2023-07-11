import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medley/objects/platform.dart';
import 'package:medley/objects/playlist.dart';

import 'package:medley/objects/user.dart';
import 'package:medley/services/google_auth.dart';
import 'package:medley/services/medley.dart';
import 'package:medley/services/spotify_auth.dart';
import 'package:path_provider/path_provider.dart';

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
        },
    );

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
      _storage.delete(key: _sp.storageKey);
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

  void createCustomPlaylist(BuildContext context) async {
    String value = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Custom Playlist'),
          content: TextField(
            decoration: const InputDecoration(
              // border: OutlineInputBorder(),
              border: UnderlineInputBorder(),
              hintText: 'Enter playlist name',
            ),
            onChanged: (text) => value = text,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Create'),
              onPressed: () {
                final existing = _allPlaylists.custom.where((pl) => pl.listId == value).toList();
                if (existing.isEmpty) {
                  _allPlaylists.custom.add(Playlist(
                    value,
                    AudioPlatform.empty(),
                    value,
                    '',
                    0,
                    [],
                  ));
                  _allPlaylists.save();
                  notifyListeners();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void removePlaylist(Playlist pl) async {
    switch (pl.platform.id) {
      case 0:
        _allPlaylists.custom.remove(pl);
        break;
      case 1:
        _allPlaylists.youtube.remove(pl);
        break;
      case 2:
        _allPlaylists.spotify.remove(pl);
        break;
      case 3:
        _allPlaylists.soundcloud.remove(pl);
        break;
      default:
        break;
    }
    final Directory dir = await getStorageDirectory();
    final Directory listDir = Directory('${dir.path}/${pl.listId}');
    if (await listDir.exists()) await listDir.delete(recursive: true);
    _allPlaylists.save();
    notifyListeners();
  }

  void savePlaylist(Playlist pl) async {
    if (pl.songs.isEmpty) pl = await MedleyService().getSongs(getToken(pl.platform), pl);
    Playlist newPl = Playlist(pl.title, AudioPlatform.empty(), pl.listId, pl.imgUrl, pl.numberOfTracks, pl.songs);

    newPl = await downloadPlaylist(newPl, pl.platform);
    newPl.isDownloaded = true;

    _allPlaylists.custom.add(newPl);
    _allPlaylists.save();
    notifyListeners();
  }

  void editPlaylist(BuildContext context, Playlist pl) {
    String playlistName = pl.title;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Playlist'),
          content: TextField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Enter playlist name',
            ),
            onChanged: (text) => playlistName = text,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Save'),
              onPressed: () {
                pl.title = playlistName;
                _allPlaylists.save();
                notifyListeners();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Playlist> downloadPlaylist(Playlist pl, AudioPlatform oldPlatform) async {
    final dir = await getStorageDirectory();
    pl = await MedleyService().downloadSongs(dir, pl, oldPlatform);
    return pl;
  }

  Future<Directory> getStorageDirectory() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir;
  }
}
