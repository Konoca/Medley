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
import 'package:medley/screens/home.dart';
import 'package:medley/services/medley.dart';
import 'package:provider/provider.dart';


Widget loadingCircle() {
    return Container(
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Color(0xFF837AFA)),
    );
  }

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  Widget results = loadingCircle();

  search(String query) async {
    UserData user = context.read<UserData>();
    final results = await MedleyService().search(query, 10, user);

    setState(() => this.results = resultLayout(
      results['1'],
      results['2'],
      results['3']
    ));
  }

  Widget resultLayout(List<Song> yt, List<Song> sp, List<Song> sc) {
    Widget ytList = resultList(yt);
    Widget spList = resultList(sp);
    Widget scList = resultList(sc);

    List<Widget> w = [
      isMobile() ? mobileSearchBar() : Container(),
      platformLabel('assets/icons/youtube.png', "Youtube"),
      ytList,
      platformLabel('assets/icons/spotify.png', "Spotify"),
      spList,
      platformLabel('assets/icons/soundcloud.png', "Soundcloud"),
      scList
    ];

    // return Row(children: w);
    // if (isMobile()) {
    //   return Column(
    //     mainAxisSize: MainAxisSize.max,
    //     children: [
    //       mobileSearchBar(),
    //       ListView(
    //         children: w
    //       ),
    //     ]
    //   );
    // }
    return ListView(children: w);
  }

  Widget resultList(List<Song> songs) {
    if (songs.isEmpty) return Container();

    List<Widget> results = [];
    for (Song s in songs) {
      results.add(songTile(s));
    }

    return Column(children: results);
  }

  Widget songTile(Song song) {
    return InkWell(
      onTap: () {
        context.read<CurrentlyPlaying>().setPlaylist(
          Playlist(
            '',
            song.platform,
            '',
            '',
            0,
            [song]
          ),
          song: song
        );
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
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save to'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<UserData>().saveToPlaylist(context, Playlist.empty(), song);
                }
              ),
              const ListTile(),
            ],
          );
        });
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0x801E1E1E),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SquareImage(NetworkImage(song.imgUrl), 50),
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

  Widget mobileSearchBar() {
    return SizedBox(
      child: TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        initialValue: query,
        onFieldSubmitted: (v) {
          setState(() => query = v);
          context.read<CurrentPage>().setSearchQuery(v);
          search(query);
          setState(() => results = Column(
            children: [
              mobileSearchBar(),
              loadingCircle(),
            ]
          ));
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String q = context.watch<CurrentPage>().searchQuery;

    if (q != '' && q != query) {
      search(q);
      setState(() => query = q);
    }

    if (isMobile() && q == '' && query == '') {
      setState(() => results = mobileSearchBar());
      // if (q == '' && query == '') setState(() => results = Container());
      // return ListView(
      //   children: [
      //     mobileSearchBar(),
      //     results,
      //   ]
      // );
    }

    return results;
  }
}
