import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;
  
  final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> categoriesNavigatorKey = GlobalKey<NavigatorState>();

  void onTabTapped(int index) {
    if (selectedIndex.value == index) {
      if (index == 0) {
        homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (index == 1) {
        categoriesNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    }
    selectedIndex.value = index;
  }

  bool handleBackNavigation() {
    NavigatorState? currentNav;
    if (selectedIndex.value == 0) currentNav = homeNavigatorKey.currentState;
    if (selectedIndex.value == 1) currentNav = categoriesNavigatorKey.currentState;

    if (currentNav != null && currentNav.canPop()) {
      currentNav.pop();
      return true; // Handled
    }
    
    if (selectedIndex.value != 0) {
      selectedIndex.value = 0;
      return true; // Handled
    }
    
    return false; // Not handled, let system handle it (exit app)
  }
}
