import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:just_audio_background/just_audio_background.dart';

import 'package:medley/layout.dart';
import 'package:medley/objects/player.dart';
import 'package:medley/providers/page_provider.dart';
import 'package:medley/providers/song_provider.dart';
import 'package:medley/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

late CustomAudioPlayer _audioHandler;

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(800, 600));

    WidgetsFlutterBinding.ensureInitialized();
  }
  if (kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    _audioHandler = await AudioService.init(
      builder: () => CustomAudioPlayer(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.konoca.medley.channel.audio',
        androidNotificationChannelName: 'Medley',
      ),
    );
  }
  else {
    _audioHandler = CustomAudioPlayer();
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CurrentlyPlaying(_audioHandler)),
      ChangeNotifierProvider(create: (_) => UserData()),
      ChangeNotifierProvider(create: (_) => CurrentPage()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<UserData>().login();
    context.read<CurrentlyPlaying>().setUser(context.read<UserData>());
    return MaterialApp(
      title: 'Medley',
      theme: ThemeData.dark(useMaterial3: true),
      color: Colors.blue,
      home: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [Color(0x8073A5FD), Colors.black],
          ),
        ),
        child: const PageLayout(),
      ),
    );
  }
}
