import 'package:flutter/material.dart';

import 'package:medley/layout.dart';
import 'package:medley/providers/song_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => CurrentlyPlaying())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medley',
      theme: ThemeData.dark(useMaterial3: true),
      color: Colors.blue,
      home: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x8073A5FD), Colors.black],
          ),
        ),
        child: const PageLayout(),
      ),
    );
  }
}

