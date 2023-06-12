import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:http/http.dart' as http;

import 'package:medley/objects/user.dart';

const scopes = [
  'https://www.googleapis.com/auth/youtube.readonly',
  'https://www.googleapis.com/auth/userinfo.profile',
];

class GoogleAuthService {
  signInToGoogle() async {
    try {
      if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
        return await _mobileLogin();
      }
      return await _desktopLogin();
    } catch (e) {
      print(e);
      return YoutubeAccount.blank();
    }
  }

  _mobileLogin() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn(
      scopes: scopes,
    ).signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    return YoutubeAccount(
      gAuth.accessToken!,
      gUser.photoUrl!,
      true,
      gUser.displayName!,
    );
  }

  _desktopLogin() async {
    final result = await DesktopWebviewAuth.signIn(GoogleSignInArgs(
      clientId: dotenv.env['GOOGLE_CLIENT_ID']!,
      redirectUri: dotenv.env['GOOGLE_REDIRECT_URL']!,
      scope: scopes.join(' '),
    ));
    String accessToken = result!.accessToken!;

    final userData = await http.get(
      Uri.https(
        'www.googleapis.com',
        '/oauth2/v3/userinfo',
        {
          'access_token': accessToken,
        },
      ),
    );

    final data = (jsonDecode(userData.body) as Map);

    return YoutubeAccount(
      accessToken,
      data['picture'],
      true,
      data['name'],
    );
  }
}
