import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:medley/layout.dart';
import 'package:medley/providers/page_provider.dart';
import 'package:medley/providers/song_provider.dart';
import 'package:medley/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(800, 600));
    // WindowManager.instance.setMaximumSize(const Size(1200, 600));
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CurrentlyPlaying()),
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
