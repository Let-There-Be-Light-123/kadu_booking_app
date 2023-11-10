import 'package:flutter/material.dart';

class FavoriteModel extends ChangeNotifier {
  Map<String, bool> _favorites = {};

  bool isFavorite(String id) {
    return _favorites[id] ?? false;
  }

  void toggleFavorite(String id) {
    _favorites[id] = !_favorites[id]!;
    print(_favorites[id]);
    notifyListeners();
  }
}
