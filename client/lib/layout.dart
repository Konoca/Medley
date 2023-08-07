import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:medley/components/image.dart';

import 'package:medley/components/media_controls.dart';
import 'package:medley/components/text.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medley/objects/platform.dart';
import 'package:medley/objects/song.dart';
import 'package:medley/providers/page_provider.dart';

import 'package:medley/screens/home.dart';
import 'package:medley/screens/playlist.dart';
import 'package:medley/screens/search.dart';
import 'package:medley/screens/settings.dart';

import 'package:medley/providers/song_provider.dart';
import 'package:provider/provider.dart';

class PageLayout extends StatefulWidget {
  const PageLayout({super.key});

  @override
  State<PageLayout> createState() => _PageLayoutState();
}

class _PageLayoutState extends State<PageLayout> {
  double progress = 0;
  Duration songDuration = Duration.zero;
  String query = '';

  Widget selectPage(BuildContext ctx) {
    int pageIndex = context.watch<CurrentPage>().pageIndex;
    Widget p = const HomePage();
    if (pageIndex == 1) p = const SearchPage();
    // if (pageIndex == 2) p = const AccountPage();
    if (pageIndex == 2) p = const SettingsPage();
    if (pageIndex == 3) p = const PlaylistPage();
    return Column(
      children: [
        if (!isMobile()) desktopMenuBar(ctx),
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

    player.durationStream.listen((duration) {
      // work around until I figure out *why*
      // apple devices misread the duration of .m4a
      if (duration == null) return;

      if (isApple() &&
          song.platform.id == AudioPlatform.youtube().id &&
          song.platform.codec == 'm4a') {
        duration =
            Duration(microseconds: (duration.inMicroseconds.toDouble() ~/ 2));
      }

      setState(() => songDuration = duration!);
    });

    player.positionStream.listen((position) {
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

    player.playerStateStream.listen((state) {
      if (songDuration == Duration.zero || progress < 1) return;
      if (state.processingState != ProcessingState.completed) return;

      nextSong(ctx);
    });

    if (display || kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return Column(
        children: [
          durationBar(context),
          controlBar(context),
        ],
      );
    }
    return Container();
  }

  Widget durationBar(BuildContext context) {
    if (isMobile()) {
      return LinearProgressIndicator(
        color: Colors.white,
        value: progress,
      );
    }
    return durationSlider(context);
  }

  Widget durationSlider(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: SliderComponentShape.noThumb,
      ),
      child: Slider(
        activeColor: Colors.white,
        inactiveColor: const Color(0xFF404040),
        value: progress,
        onChanged: (v) {},
        // onChanged: (v) => context.read<CurrentlyPlaying>().seek(
        //       Duration(microseconds: (songDuration.inMicroseconds * v).toInt()),
        //     ),
        onChangeEnd: (v) => context.read<CurrentlyPlaying>().seek(
              Duration(
                microseconds: (songDuration.inMicroseconds * v).toInt(),
              ),
            ),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget controlBar(BuildContext context) {
    if (isMobile()) {
      return InkWell(
        onTap: () => mobileControlDrawer(context),
        child: Container(
          alignment: Alignment.bottomCenter,
          decoration: const BoxDecoration(color: Color(0x801E1E1E)),
          child: const MobileMediaControls(),
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
    int pageIndex = context.watch<CurrentPage>().pageIndex;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        child: selectPage(context),
      ),
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
        currentIndex: pageIndex < 3 ? pageIndex : 0,
        onTap: (value) {
          context.read<CurrentPage>().setPageIndex(value);
        },
      ),
    );
  }

  Widget getImage(CurrentlyPlaying cp) {
    if (cp.song.isDownloaded) {
      return SquareImage(
        FileImage(File(cp.song.imgUrl)),
        300,
        isLoading: cp.isCaching,
      );
    }
    return SquareImage(
      NetworkImage(cp.song.imgUrl),
      300,
      isLoading: cp.isCaching,
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
              getImage(context.watch<CurrentlyPlaying>()),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: ScrollingText(
                  context.watch<CurrentlyPlaying>().song.title,
                  width: MediaQuery.of(context).size.width * 0.9,
                  style: const TextStyle(fontSize: 40),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: ScrollingText(
                  context.watch<CurrentlyPlaying>().song.artist,
                  width: MediaQuery.of(context).size.width * 0.9,
                  style: const TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 50),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: durationSlider(context),
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

  Widget desktopMenuBar(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(45)),
                  color: Color(0x80404040),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.read<CurrentPage>().setPageIndex(0),
                  // color: const Color(0xff1E1E1E),
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    // labelText: 'Search',
                  ),
                  onSubmitted: (v) {
                    setState(() => query = v);
                    context.read<CurrentPage>().search(query);
                  }
                ),
              ),
            ],
          ),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(45)),
              color: Color(0x80404040),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.read<CurrentPage>().setPageIndex(2),
              // color: const Color(0xff1E1E1E),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget desktopLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: selectPage(context),
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
