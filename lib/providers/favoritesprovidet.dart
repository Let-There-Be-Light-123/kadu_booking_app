import 'package:flutter/foundation.dart';

class FavoritesProvider extends ChangeNotifier {
  List<int> _favoriteProperties = [];

  List<int> get favoriteProperties => _favoriteProperties;

  void addToFavorites(int propertyId) {
    _favoriteProperties.add(propertyId);
    // TODO: Update the backend to save the favorite property for the user
    notifyListeners();
  }

  void removeFromFavorites(int propertyId) {
    _favoriteProperties.remove(propertyId);
    // TODO: Update the backend to remove the favorite property for the user
    notifyListeners();
  }

  // TODO: Add a method to fetch the favorite properties for the user from the backend
}
