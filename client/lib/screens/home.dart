import 'package:flutter/material.dart';
import 'package:medley/components/image.dart';
import 'package:medley/components/text.dart';
import 'package:medley/providers/page_provider.dart';
import 'package:medley/providers/song_provider.dart';
import 'package:medley/providers/user_provider.dart';

import 'package:provider/provider.dart';
import 'package:medley/objects/playlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double playlistSize = 200;

  Widget createTile(Playlist pl) {
    return InkWell(
      onTap: () {
        context.read<CurrentPage>().setPlaylist(pl);
        context.read<CurrentPage>().setPageIndex(3);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x80000000),
          borderRadius: BorderRadius.circular(15),
        ),
        height: playlistSize + 10,
        width: playlistSize,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            const Spacer(),
            SquareImage(
              NetworkImage(pl.imgUrl),
              playlistSize - 50,
            ),
            ScrollingText(
              pl.title,
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
            Text(
              '${pl.numberOfTracks.toString()} tracks',
              style: const TextStyle(
                color: Color(0x80FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> fetchPlaylists(BuildContext context) {
    List<Widget> w = [];
    double width = MediaQuery.of(context).size.width;
    int columns = (width / (playlistSize + 10)).floor();

    while (columns < 2) {
      setState(() => playlistSize -= 10);
      columns = (width / (playlistSize + 10)).floor();
    }

    AllPlaylists playlists = context.watch<UserData>().allPlaylists;

    if (playlists.isEmpty()) {
      return [
        Container(
            alignment: Alignment.center,
            height: 500,
            child: const Text(
              'Get started by linking an account!',
              style: TextStyle(color: Color(0xFF1E1E1E)),
            ))
      ];
    }

    if (playlists.custom.isNotEmpty) {
      w = platformList(w, playlists.custom, columns);
    }

    if (playlists.youtube.isNotEmpty) {
      w.add(platformLabel('assets/icons/youtube.png', "Youtube"));
      w = platformList(w, playlists.youtube, columns);
    }

    if (playlists.spotify.isNotEmpty) {
      w.add(platformLabel('assets/icons/spotify.png', "Spotify"));
      w = platformList(w, playlists.spotify, columns);
    }

    if (playlists.soundcloud.isNotEmpty) {
      w.add(platformLabel('assets/icons/soundcloud.png', "Soundcloud"));
      w = platformList(w, playlists.soundcloud, columns);
    }

    return w;
  }

  List<Widget> platformList(List<Widget> w, List<Playlist> pls, int columns) {
    List<Widget> children = [];
    int i = 0;
    for (Playlist pl in pls) {
      if (i == -1) {
        w.add(Row(children: children));
        children = [];
        i = 0;
      }
      children.add(createTile(pl));
      i++;
      if (i >= columns) i = -1;
    }
    w.add(Row(children: children));
    return w;
  }

  Widget platformLabel(String asset, String name) {
    return Row(
      children: [
        Image.asset(
          asset,
          height: 40,
          color: Colors.white,
        ),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(5),
        scrollDirection: Axis.vertical,
        children: fetchPlaylists(context),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => context.read<CurrentlyPlaying>().cache.clear(),
        onPressed: () => context.read<UserData>().createCustomPlaylist(context),
        backgroundColor: const Color(0x8073A5FD),
        mini: true,
        child: const Icon(Icons.add),
        // child: const Text('Clear cache'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
