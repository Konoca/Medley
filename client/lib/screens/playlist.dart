import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medley/components/image.dart';
import 'package:medley/components/media_controls.dart';
import 'package:medley/components/text.dart';
import 'package:medley/objects/playlist.dart';
import 'package:medley/objects/song.dart';
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
  Widget getImage(Song s) {
    if (s.isDownloaded) return SquareImage(FileImage(File(s.imgUrl)), 50);
    return SquareImage(NetworkImage(s.imgUrl), 50);
  }

  Color getColor(Song s) {
    if (s.isDownloaded) return const Color(0xFF64F3D3);
    return Colors.transparent;
  }

  Widget songTile(Playlist pl, Song song) {
    return InkWell(
      onTap: () {
        context.read<CurrentlyPlaying>().setPlaylist(pl, song: song);
      },
      onSecondaryTap: () {
        // TODO implement for desktop/web
        if (kIsWeb) return;
      },
      onLongPress: () {
        if (kIsWeb) return;
        showModalBottomSheet(context: context, builder: (builder) {
          return Wrap(
            children: [
              pl.platform.id == 0 && !song.isDownloaded ? ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  context.read<UserData>().downloadSong(pl, song);
                  Navigator.of(context).pop();
                  context.read<CurrentPage>().setPlaylist(pl);
                }
              ) : Container(),
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save to'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<UserData>().saveToPlaylist(context, song);
                }
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove'),
                onTap: () {
                  context.read<UserData>().removeFromPlaylist(pl, song);
                  Navigator.of(context).pop();
                  context.read<CurrentPage>().setPlaylist(pl);
                }
              ),
              const ListTile(),
            ],
          );
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: song == context.watch<CurrentlyPlaying>().song
              ? const Color(0xFF1E1E1E)
              : const Color(0x801E1E1E),
          border: Border(
            left: BorderSide(
              color: song.isDownloaded
                ? const Color(0xFF64F3D3)
                : Colors.transparent,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                getImage(song),
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
                if (!isMobile())
                  Text(
                    song.duration.substring(0, song.duration.length - 7),
                    style: const TextStyle(
                      color: Color(0x80FFFFFF),
                    ),
                    textAlign: TextAlign.right,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Playlist pl = context.watch<CurrentPage>().playlistToDisplay;

    if (pl.numberOfTracks == 0) {
      return Container(
        alignment: Alignment.center,
        child: const Text(
          'Playlist is empty!',
          style: TextStyle(color: Color(0xFF1E1E1E)),
        )
      );
    }

    if (pl.songs.isEmpty) {
      context.watch<UserData>().updatePlaylist(pl);
      return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFF837AFA)),
      );
    }

    return ListView.builder(
      itemCount: pl.songs.length,
      itemBuilder: (context, index) {
        return songTile(pl, pl.songs[index]);
      },
    );
  }
}
