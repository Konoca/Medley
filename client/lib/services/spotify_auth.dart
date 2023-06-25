import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medley/components/media_controls.dart';
import 'package:medley/objects/user.dart';
import 'package:spotify/spotify.dart' as sp;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

final scopes = [
  'playlist-read-private',
  'playlist-read-collaborative',
  'user-library-read',
  'streaming',
];

class SpotifyAuthService {
  signIn(BuildContext context) async {
    final credentials = sp.SpotifyApiCredentials(
        dotenv.env['SPOTIFY_CLIENT_ID']!, dotenv.env['SPOTIFY_CLIENT_SECRET']!);
    final grant = sp.SpotifyApi.authorizationCodeGrant(credentials);

    final authUri = grant.getAuthorizationUrl(
      Uri.parse(dotenv.env['SPOTIFY_REDIRECT_URL']!),
      scopes: scopes,
    );

    String response = '';

    if (kIsWeb) {
      // TODO Web Spotify login
      return SpotifyAccount.blank();
    }

    if (isMobile()) {
      response = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Spotify'),
            ),
            body: _SpotifyLoginWebViewMobile(
              loginUrl: authUri,
              redirectUrl: dotenv.env['SPOTIFY_REDIRECT_URL']!,
            ),
          ),
        ),
      );
      return await clientFromResponse(response, grant);
    }
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      response = await _SpotifyLoginWebViewDesktop(
        loginUrl: authUri.toString(),
        redirectUrl: dotenv.env['SPOTIFY_REDIRECT_URL']!,
      ).login();
      return await clientFromResponse(response, grant);
    }
  }

  clientFromResponse(
      String response, oauth2.AuthorizationCodeGrant grant) async {
    if (response == '') return SpotifyAccount.blank();

    final spotify = sp.SpotifyApi.fromAuthCodeGrant(grant, response);
    final user = await spotify.me.get();
    final newClient = await spotify.client;

    return SpotifyAccount(
      spotify,
      newClient.credentials.refreshToken!,
      newClient.credentials.accessToken,
      // user.images!.last.url!,
      true,
      user.displayName ?? '',
    );
  }

  clientFromRefreshToken(String refreshToken, String accessToken) async {
    final spotifyCredentials = sp.SpotifyApiCredentials(
      dotenv.env['SPOTIFY_CLIENT_ID'],
      dotenv.env['SPOTIFY_CLIENT_SECRET'],
      accessToken: accessToken,
      refreshToken: refreshToken,
      scopes: scopes,
      expiration: DateTime.now(),
    );

    final spotify = sp.SpotifyApi(spotifyCredentials);
    final user = await spotify.me.get();
    final newClient = await spotify.client;

    return SpotifyAccount(
      spotify,
      newClient.credentials.refreshToken!,
      newClient.credentials.accessToken,
      // user.images!.last.url!,
      true,
      user.displayName ?? '',
    );
  }

  clientFromStorage(String storageValue) async {
    final split = storageValue.split('/');
    return clientFromRefreshToken(split[0], split[1]);
  }
}

class _SpotifyLoginWebViewMobile extends StatelessWidget {
  final Uri loginUrl;
  final String redirectUrl;

  const _SpotifyLoginWebViewMobile(
      {required this.loginUrl, required this.redirectUrl});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)

          // ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith(redirectUrl)) {
                  Navigator.of(context).pop(request.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(loginUrl));
  }
}

class _SpotifyLoginWebViewDesktop {
  final String loginUrl;
  final String redirectUrl;

  String response = '';

  _SpotifyLoginWebViewDesktop(
      {required this.loginUrl, required this.redirectUrl});

  Future<String> login() async {
    final webview = await WebviewWindow.create();
    webview
      ..addOnUrlRequestCallback((url) {
        if (url.startsWith(redirectUrl)) {
          response = url;
          webview.close();
        }
      })
      ..launch(loginUrl);

    await webview.onClose.whenComplete(
      () {},
    );

    return response;
  }
}
