import 'package:flutter/material.dart';

class ChangeButtonNavigationBarIndex extends ChangeNotifier {

  //changes the bottom navigation bar index of the application
  int currentIndex = 0;
  void updateCurrentIndex(int currentIndex) {
    this.currentIndex = currentIndex;
    notifyListeners();
  }

  //this is not supposed to be here but this would handle the
  // showing and hiding of the loading when a user  attempts to change their profile picture
  bool showProfilePicChangeLoader = false;
  void updateShowProfilePicChangeLoader (bool showProfilePicChangeLoader) {
    this.showProfilePicChangeLoader = showProfilePicChangeLoader;
    notifyListeners();
  }

  //stores the prices of the cylinders
  Map prices = {};
  void updatePrices(Map prices) {
    this.prices = prices;
    notifyListeners();
  }
}