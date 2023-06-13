import 'package:flutter/material.dart';
import 'package:medley/components/image.dart';
import 'package:medley/components/text.dart';
import 'package:medley/objects/playlist.dart';
import 'package:medley/providers/page_provider.dart';
import 'package:medley/providers/song_provider.dart';
import 'package:medley/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  Widget songList(Playlist pl) {
    return Column(
      children: pl.songs.map<Widget>((song) {
        return InkWell(
          onTap: () {
            context.read<CurrentlyPlaying>().setPlaylist(pl, song: song);
          },
          child: Container(
            decoration: BoxDecoration(
              color: song == context.watch<CurrentlyPlaying>().song
                  ? const Color(0xFF1E1E1E)
                  : const Color(0x801E1E1E),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SquareImage(
                  NetworkImage(song.imgUrl),
                  50,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScrollingText(
                        song.title,
                        width: MediaQuery.sizeOf(context).width * 0.75,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ScrollingText(
                        song.artist,
                        width: MediaQuery.sizeOf(context).width * 0.75,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Playlist pl = context.watch<CurrentPage>().playlistToDisplay;

    if (pl.songs.isEmpty) {
      context.watch<UserData>().updatePlaylist(pl);
      return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFF837AFA)),
      );
    }

    return ListView(
      children: [
        songList(pl),
      ],
    );
  }
}
