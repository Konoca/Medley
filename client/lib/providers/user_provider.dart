import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medley/objects/platform.dart';
import 'package:medley/objects/playlist.dart';
import 'package:medley/objects/song.dart';

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
    fetchPlaylists(yt: true);
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
                  fetchPlaylists(yt: true);
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
    fetchPlaylists(spotify: true);
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
                  fetchPlaylists(spotify: true);
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

  Future<AllPlaylists> fetchPlaylists({yt = false, spotify = false, soundcloud = false}) async {
    if (yt) _allPlaylists.youtube = await MedleyService().getYoutubePlaylists(this);
    if (spotify) _allPlaylists.spotify = await MedleyService().getSpotifyPlaylists(this);
    // TODO soundcloud

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
                    'custom/$value',
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

  void removeFromPlaylist(Playlist pl, Song s) async {
    pl.songs.remove(s);
    pl.numberOfTracks--;

    final Directory dir = await getStorageDirectory();
    final File f = File('${dir.path}/${pl.listId}/${s.platformId}.${s.platform.codec}');
    if (await f.exists()) await f.delete();

    final File f2 = File(s.imgUrl);
    if (await f2.exists()) await f2.delete();

    _allPlaylists.save();
    notifyListeners();
    // TODO doesnt update in real time
  }

  void savePlaylist(Playlist pl) async {
    if (pl.songs.isEmpty) pl = await MedleyService().getSongs(getToken(pl.platform), pl);
    Playlist newPl = Playlist.copy(pl);
    newPl.platform = AudioPlatform.empty();

    Playlist temp = Playlist.copy(pl);
    temp.isDownloading = true;
    _allPlaylists.custom.add(temp);
    notifyListeners();

    newPl = await downloadPlaylist(newPl, pl.platform);
    newPl.isDownloaded = true;

    _allPlaylists.custom.remove(temp);
    _allPlaylists.custom.add(newPl);
    _allPlaylists.save();
    notifyListeners();
  }

  void saveToPlaylist(BuildContext context, Playlist oldPlaylist, Song s) {
    if (_allPlaylists.custom.isEmpty) return;

    Playlist pl = _allPlaylists.custom.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Playlist'),
          content: DropdownButtonFormField<Playlist>(
            value: pl,
            items: _allPlaylists.custom.map<DropdownMenuItem<Playlist>>((Playlist v) {
              return DropdownMenuItem<Playlist>(
                value: v,
                child: Text(v.title),
              );
            }).toList(),
            onChanged: (Playlist? v) {
              pl = v!;
            }
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
              onPressed: () async {
                Song newS = Song.copy(s);

                if (s.isDownloaded) {
                  Directory dir = await getStorageDirectory();

                  // img
                  String fileExt = newS.imgUrl.split('.').last;
                  String newPath = '${dir.path}/${pl.listId}/${newS.platformId}.$fileExt';
                  File f = File(newS.imgUrl);
                  File f2 = await f.copy(newPath);
                  newS.imgUrl = f2.path;

                  // song
                  String newPath2 = '${dir.path}/${pl.listId}/${newS.platformId}.${newS.platform.codec}';
                  File f3 = File('${dir.path}/${oldPlaylist.listId}/${s.platformId}.${s.platform.codec}');
                  await f3.copy(newPath2);

                  newS.isDownloaded = true;
                }
                if (!s.isDownloaded) downloadSong(pl, newS);

                pl.songs.add(newS);
                pl.numberOfTracks++;

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
    _allPlaylists.save();
    notifyListeners();
    return pl;
  }

  Future<Playlist> downloadSong(Playlist pl, Song s) async {
    final dir = await getStorageDirectory();
    pl = await MedleyService().downloadSong(dir, pl, s);
    _allPlaylists.save();
    notifyListeners();
    return pl;
  }

  Future<Directory> getStorageDirectory() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir;
  }
}
