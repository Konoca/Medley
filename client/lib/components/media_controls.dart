import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:medley/components/image.dart';
import 'package:medley/components/text.dart';

import 'package:medley/providers/song_provider.dart';
import 'package:provider/provider.dart';

class MediaControls extends StatefulWidget {
  const MediaControls({super.key});

  @override
  State<MediaControls> createState() => _MediaControlsState();
}

class MobileMediaControls extends StatefulWidget {
  const MobileMediaControls({super.key});

  @override
  State<MobileMediaControls> createState() => _MobileMediaControlsState();
}

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key});

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class Controls extends StatefulWidget {
  const Controls({super.key});

  @override
  State<Controls> createState() => _ControlsState();
}

class Volume extends StatefulWidget {
  const Volume({super.key});

  @override
  State<Volume> createState() => _VolumeState();
}

bool isMobile() {
  return (!kIsWeb && (Platform.isIOS || Platform.isAndroid));
}

class _MediaControlsState extends State<MediaControls> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NowPlaying(),
        Controls(),
        Volume(),
      ],
    );
  }
}

class _MobileMediaControlsState extends State<MobileMediaControls> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const NowPlaying(),
        IconButton(
          onPressed: () => context.read<CurrentlyPlaying>().togglePlaying(),
          icon: context.watch<CurrentlyPlaying>().isPlaying
              ? const Icon(Icons.pause_rounded)
              : const Icon(Icons.play_arrow_rounded),
          iconSize: 50,
          splashRadius: 25,
        ),
      ],
    );
  }
}

class _NowPlayingState extends State<NowPlaying> {
  @override
  Widget build(BuildContext context) {
    if (!context.watch<CurrentlyPlaying>().display) {
      return Container(
        height: 75,
        width: 190,
        padding: const EdgeInsets.symmetric(horizontal: 10),
      );
    }

    return Row(
      children: [
        SquareImage(
          NetworkImage(context.watch<CurrentlyPlaying>().song.imgUrl),
          74,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScrollingText(
                context.watch<CurrentlyPlaying>().song.title,
                width: MediaQuery.of(context).size.width / 2,
              ),
              ScrollingText(
                context.watch<CurrentlyPlaying>().song.artist,
                width: MediaQuery.of(context).size.width / 2,
                style: const TextStyle(
                  color: Color(0x80FFFFFF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

List<Widget> controlGroup(BuildContext context, double iconSize) {
  return [
    IconButton(
      onPressed: () => context.read<CurrentlyPlaying>().toggleShuffle(),
      icon: const Icon(Icons.shuffle),
      iconSize: iconSize,
      color:
          context.watch<CurrentlyPlaying>().shuffle ? Colors.blue : Colors.grey,
    ),
    IconButton(
      onPressed: () => context.read<CurrentlyPlaying>().prevSong(),
      icon: const Icon(Icons.fast_rewind_rounded),
      iconSize: iconSize,
    ),
    IconButton(
      onPressed: () => context.read<CurrentlyPlaying>().togglePlaying(),
      icon: context.watch<CurrentlyPlaying>().isPlaying
          ? const Icon(Icons.pause_circle)
          : const Icon(Icons.play_circle),
      iconSize: iconSize * 2,
    ),
    IconButton(
      onPressed: () => context.read<CurrentlyPlaying>().nextSong(),
      icon: const Icon(Icons.fast_forward_rounded),
      iconSize: iconSize,
    ),
    IconButton(
      onPressed: () => context.read<CurrentlyPlaying>().toggleLoop(),
      icon: const Icon(Icons.loop),
      iconSize: iconSize,
      color: context.watch<CurrentlyPlaying>().loop ? Colors.blue : Colors.grey,
    ),
  ];
}

class _ControlsState extends State<Controls> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: controlGroup(context, 25),
    );
  }
}

class _VolumeState extends State<Volume> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      height: 75,
      child: Row(
        children: [
          const Icon(Icons.volume_up),
          Slider(
            activeColor: Colors.white,
            inactiveColor: const Color(0xFF404040),
            value: context.watch<CurrentlyPlaying>().volume,
            onChanged: (v) => context.read<CurrentlyPlaying>().setVolume(v),
            thumbColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
