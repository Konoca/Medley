import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:medley/providers/song_provider.dart';
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
      onTap: () => context.read<CurrentlyPlaying>().setPlaylist(pl),
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
            Image(image: NetworkImage(pl.songs[0].imgUrl), height: playlistSize - 50),
            Text(pl.title),
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

  List<Widget> fetchPlaylists(double width) {
    List<Widget> w = [];
    int columns = (width / (playlistSize+10)).floor();

    while (columns < 2) {
      setState(() => playlistSize -= 10);
      columns = (width / (playlistSize+10)).floor();
    }

    AllPlaylists playlists = AllPlaylists.fetch();

    if (playlists.custom.isNotEmpty) {
      w = platformList(w, playlists.custom, columns);
    }

    if (playlists.youtube.isNotEmpty) {
      w.add(platformLabel('assets/icons/youtube.png', "Youtube"));
      w = platformList(w, playlists.youtube, columns);
    }

    if (playlists.spotify.isNotEmpty) {
      w.add(platformLabel('assets/icons/spotofy.png', "Spotify"));
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
    return ListView(
      padding: const EdgeInsets.all(5),
      scrollDirection: Axis.vertical,
      children: fetchPlaylists(MediaQuery.of(context).size.width),
    );
  }
}
