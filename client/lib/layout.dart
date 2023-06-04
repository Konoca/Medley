import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:medley/media_controls.dart';

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

  Widget selectPage(bool display) {
    Widget p = const HomePage();
    if (pageIndex == 1) p = const SearchPage();
    if (pageIndex == 2) p = const AccountPage();
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: p,
        ),
        nowPlaying(display),
      ],
    );
  }

  Widget nowPlaying(bool display) {
    if (display || kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      return Container(
        alignment: Alignment.bottomCenter,
        decoration: const BoxDecoration(color: Color(0x801E1E1E)),
        child: const MediaControls(),
      );
    }
    return Container();
  }

  Widget mobileLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 20,
      ),
      body: selectPage(context.watch<CurrentlyPlaying>().display),
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

  Widget desktopLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 50,
      ),
      body: selectPage(context.watch<CurrentlyPlaying>().isPlaying),
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
    if (kIsWeb) {
      return desktopLayout();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return mobileLayout();
    }
    return desktopLayout();
  }
}
