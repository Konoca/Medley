import 'package:google_sign_in/google_sign_in.dart';

class Account {
  bool _isAuthenticated;
  String _userName;

  bool get isAuthenticated => _isAuthenticated;
  String get userName => _userName;

  Account(this._isAuthenticated, this._userName);

  Account.blank()
      : _isAuthenticated = false,
        _userName = '';

  void login(String userName) {
    _isAuthenticated = true;
    _userName = userName;
  }
}

class YoutubeAccount extends Account {
  // Mobile only
  late GoogleSignInAccount _gUser;
  late GoogleSignInAuthentication _gAuth;
  GoogleSignInAccount get user => _gUser;
  GoogleSignInAuthentication get auth => _gAuth;
  // end Mobile only

  late String _accessToken;
  String get accessToken => _accessToken;

  late String _picture;
  String get picture => _picture;

  late String _refreshToken;
  String get refreshToken => _refreshToken;

  YoutubeAccount(
    this._refreshToken,
    this._accessToken,
    this._picture,
    super._isAuthenticated,
    super._userName,
  );

  YoutubeAccount.blank() : super.blank();
}

class SpotifyAccount extends Account {
  SpotifyAccount(
    super._isAuthenticated,
    super._userName,
  );

  SpotifyAccount.blank() : super.blank();
}

class SoundcloudAccount extends Account {
  SoundcloudAccount(
    super._isAuthenticated,
    super._userName,
  );

  SoundcloudAccount.blank() : super.blank();
}

class UserAccount extends Account {
  final int _userId;
  int get userId => _userId;

  UserAccount(
    this._userId,
    super._isAuthenticated,
    super._userName,
  );

  UserAccount.blank()
      : _userId = 0,
        super(false, '');
}
