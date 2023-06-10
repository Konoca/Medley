import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:medley/objects/user.dart';
import 'package:medley/services/google_auth.dart';

class UserData with ChangeNotifier {
  bool _isAuthenticated = false;

  UserAccount _user = UserAccount.blank();
  YoutubeAccount _yt = YoutubeAccount.blank();
  final SpotifyAccount _sp = SpotifyAccount.blank();
  final SoundcloudAccount _sc = SoundcloudAccount.blank();

  bool get isAuthenticated => _isAuthenticated;
  UserAccount get user => _user;
  set user(UserAccount user) => _user;
  YoutubeAccount get youtubeAccount => _yt;
  SpotifyAccount get spotifyAccount => _sp;
  SoundcloudAccount get soundcloudAccount => _sc;

  Future<bool> login() async {
    _user = UserAccount(1, true, 'Test');
    _isAuthenticated = _user.isAuthenticated;
    return _isAuthenticated;
  }

  Future<bool> loginYoutube() async {
    _yt = await GoogleAuthService().signInToGoogle();
    notifyListeners();
    return _yt.isAuthenticated;
  }

  Future<bool> loginSpotify(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Logging into spotify is not currently supported.'),
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
}
