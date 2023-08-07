import 'package:flutter/material.dart';
import 'package:medley/objects/playlist.dart';

class CurrentPage extends ChangeNotifier {
  int _pageIndex = 0;
  Playlist _playlistToDisplay = Playlist.empty();
  String _searchQuery = '';

  int get pageIndex => _pageIndex;
  Playlist get playlistToDisplay => _playlistToDisplay;
  String get searchQuery => _searchQuery;

  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  void setPlaylist(Playlist pl) {
    _playlistToDisplay = pl;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void search(String q) {
    setSearchQuery(q);
    setPageIndex(1);
  }
}
