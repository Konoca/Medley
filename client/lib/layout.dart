import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:medley/components/media_controls.dart';
import 'package:medley/objects/platform.dart';
import 'package:medley/objects/song.dart';

import 'package:medley/screens/home.dart';
import 'package:medley/screens/search.dart';
import 'package:medley/screens/account.dart';

import 'package:medley/providers/song_provider.dart';
import 'package:provider/provider.dart';

class PageLayout extends StatefulWidget {
  const PageLayout({super.key});

  @override
  State<PageLayout> createState() => _PageLayoutState();
}

class _PageLayoutState extends State<PageLayout> {
  int pageIndex = 0;
  double progress = 0;
  Duration songDuration = Duration.zero;

  Widget selectPage(BuildContext ctx) {
    Widget p = const HomePage();
    if (pageIndex == 1) p = const SearchPage();
    if (pageIndex == 2) p = const AccountPage();
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: p,
        ),
        nowPlaying(ctx),
      ],
    );
  }

  void nextSong(BuildContext ctx) {
    ctx.read<CurrentlyPlaying>().nextSong();
    setState(() => songDuration = Duration.zero);
  }

  bool isApple() {
    return !kIsWeb && (Platform.isMacOS || Platform.isIOS);
  }

  Widget nowPlaying(BuildContext ctx) {
    bool display = ctx.watch<CurrentlyPlaying>().display;
    AudioPlayer player = ctx.watch<CurrentlyPlaying>().player;
    Song song = ctx.watch<CurrentlyPlaying>().song;

    player.onDurationChanged.listen((duration) {
      // work around until I figure out *why*
      //apple devices misread the duration of .m4a
      if (isApple() && song.platform.id == AudioPlatform.youtube().id) {
        duration =
            Duration(microseconds: (duration.inMicroseconds.toDouble() ~/ 2));
      }

      setState(() => songDuration = duration);
    });

    player.onPositionChanged.listen((position) {
      if (songDuration == Duration.zero) {
        setState(() => progress = 0);
        return;
      }

      ctx.read<CurrentlyPlaying>().setProgress(position);

      setState(() {
        progress = position.inMicroseconds / songDuration.inMicroseconds;
      });

      if (progress > 1) nextSong(ctx);
    });

    player.onPlayerStateChanged.listen((state) {
      if (songDuration == Duration.zero) return;
      if (state != PlayerState.completed) return;

      nextSong(ctx);
    });

    if (display || kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return Column(
        children: [
          LinearProgressIndicator(
            color: Colors.white,
            value: progress,
          ),
          controlBar(context),
        ],
      );
    }
    return Container();
  }

  Widget controlBar(BuildContext context) {
    if (isMobile()) {
      return InkWell(
        onTap: () => mobileControlDrawer(context),
        child: Container(
          alignment: Alignment.bottomCenter,
          decoration: const BoxDecoration(color: Color(0x801E1E1E)),
          child: const MediaControls(),
        ),
      );
    }

    return Container(
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(color: Color(0x801E1E1E)),
      child: const MediaControls(),
    );
  }

  Widget mobileLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 20,
        scrolledUnderElevation: 0,
      ),
      body: selectPage(context),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFF73A5FD),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Accounts',
          ),
        ],
        currentIndex: pageIndex,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
      ),
    );
  }

  void mobileControlDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Colors.black,
      barrierColor: Colors.black,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Colors.black, Color(0x8073A5FD)],
            ),
          ),
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Image(
                image: NetworkImage(
                  context.watch<CurrentlyPlaying>().song.imgUrl,
                ),
                height: 300,
              ),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  context.watch<CurrentlyPlaying>().song.title,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  context.watch<CurrentlyPlaying>().song.artist,
                  style: const TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 50),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  color: Colors.white,
                  value: progress,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: controlGroup(context, 50),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget desktopLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 50,
      ),
      body: selectPage(context),
      floatingActionButton: Container(
        // color: const Color(0x80404040),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(45)),
          color: Color(0x80404040),
        ),
        child: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => {},
          color: const Color(0xff1E1E1E),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return mobileLayout();
    }
    return desktopLayout();
  }
}
