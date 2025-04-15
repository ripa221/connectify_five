import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Default theme mode
  ThemeMode _themeMode = ThemeMode.light;

  // Getter to retrieve the current theme mode
  //ThemeMode get themeMode => _themeMode;
  ThemeMode get themeMode => _themeMode;


  // Getter to check if current theme is dark
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Toggle theme between light and dark
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify UI to rebuild with new theme
  }
}
