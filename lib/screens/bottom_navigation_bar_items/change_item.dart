import 'package:flutter/material.dart';

class ChangeButtonNavigationBarIndex extends ChangeNotifier {
  int currentIndex = 0;
  void updateCurrentIndex(int currentIndex) {
    this.currentIndex = currentIndex;
    notifyListeners();
  }
}