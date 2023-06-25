import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
      // print(e);
      return YoutubeAccount.blank();
    }
  }

  _mobileLogin() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn(
            scopes: scopes,
            forceCodeForRefreshToken: true,
            serverClientId: dotenv.env['GOOGLE_CLIENT_ID']!)
        .signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final refreshToken = await _fetchRefreshToken(gAuth.accessToken!, gUser.serverAuthCode!);

    return YoutubeAccount(
      refreshToken,
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
        responseType: 'code token id_token',
        accessType: 'offline',
        nonce: _generateNonce(),
    ));
    final accessToken = result!.accessToken!;
    final serverAuthCode = result.code!;
    final refreshToken = await _fetchRefreshToken(accessToken, serverAuthCode);

    final data = await getUserData(accessToken);

    return YoutubeAccount(
      refreshToken,
      accessToken,
      data['picture'],
      true,
      data['name'],
    );
  }

  getUserData(String accessToken) async {
    final userData = await http.get(
      Uri.https(
        'www.googleapis.com',
        '/oauth2/v3/userinfo',
        {
          'access_token': accessToken
        },
      ),
    );
    return (jsonDecode(userData.body) as Map);
  }

  getAccessToken(String refreshToken) async {
    final result = await http.post(
      Uri.https(
        'oauth2.googleapis.com',
        '/token',
        {
          'client_id': dotenv.env['GOOGLE_CLIENT_ID']!,
          'client_secret': dotenv.env['GOOGLE_CLIENT_SECRET']!,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      ),
    );
    final data = (jsonDecode(result.body) as Map);
    return data['access_token'];
  }

  getAccountFromRefreshToken(String refreshToken) async {
    final accessToken = await getAccessToken(refreshToken);
    final userData = await getUserData(accessToken);
    return YoutubeAccount(
      refreshToken,
      accessToken,
      userData['picture'],
      true,
      userData['name'],
    );
  }

  _fetchRefreshToken(String accessToken, String serverAuthCode) async {
    // final url = Uri.parse('https://accounts.google.com/o/oauth2/token');
    // final url = Uri.parse('https://oauth2.googleapis.com/token');
    final url = Uri.https(
      'oauth2.googleapis.com',
      'token',
      {
        'code': serverAuthCode,
        'grant_type': 'authorization_code',
        'client_secret': dotenv.env['GOOGLE_CLIENT_SECRET']!,
        'client_id': dotenv.env['GOOGLE_CLIENT_ID']!,
        'redirect_uri': dotenv.env['GOOGLE_REDIRECT_URL']!
      }
    );

    // final response = await http.post(
    //   url,
    //   headers: {'Content-type': 'application/json'},
    //   // body: jsonEncode({
    //   //   'access_type': 'offline',
    //   //   // 'tokenType': serverAuthCode,
    //   //   'grant_type': 'code',
    //   //   'client_secret': dotenv.env['GOOGLE_CLIENT_SECRET']!,
    //   //   'client_id': dotenv.env['GOOGLE_CLIENT_ID']!,
    //   //   'redirect_uri': dotenv.env['GOOGLE_REDIRECT_URL']!
    //   // })
    //   body: jsonEncode({
    //     'code': serverAuthCode,
    //     'grant_type': 'authorization_code',
    //     'client_secret': dotenv.env['GOOGLE_CLIENT_SECRET']!,
    //     'client_id': dotenv.env['GOOGLE_CLIENT_ID']!,
    //     'redirect_uri': dotenv.env['GOOGLE_REDIRECT_URL']!
    //   })
    // );
    final response = await http.post(url);
    // if (response.statusCode != 200) {
    //   throw 'Refresh token request failed: ${response.statusCode}';
    // }

    final data = Map<String, dynamic>.of(jsonDecode(response.body));
    // if (data.containsKey('refreshToken')) {
    //   // here is your refresh token, store it in a secure way
    // } else {
    //   throw 'No refresh token in response';
    // }
    return data['refresh_token'];
  }

  String _generateNonce({int length = 32}) {
    const characters =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();

    return List.generate(
      length,
      (_) => characters[random.nextInt(characters.length)],
    ).join();
  }
}
