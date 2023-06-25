import 'package:flutter/material.dart';
import 'package:medley/objects/playlist.dart';

class CurrentPage extends ChangeNotifier {
  int _pageIndex = 0;
  Playlist _playlistToDisplay = Playlist.empty();

  int get pageIndex => _pageIndex;
  Playlist get playlistToDisplay => _playlistToDisplay;
  
  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  void setPlaylist(Playlist pl) {
    _playlistToDisplay = pl;
    notifyListeners();
  }
}