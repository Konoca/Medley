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
  Widget createTile(Playlist pl) {
    return InkWell(
      onTap: () => context.read<CurrentlyPlaying>().setPlaylist(pl),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x80000000),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Spacer(),
            Image(image: NetworkImage(pl.songs[0].imgUrl), height: 150),
            Text(pl.title),
            Text(
              '${pl.numberOfTracks.toString()} tracks',
              style: const TextStyle(
                color: Color(0x80FFFFFF),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      padding: const EdgeInsets.all(5),
      children: [
        createTile(Playlist.test()),
        createTile(Playlist.test2()),
      ],
    );
  }
}
