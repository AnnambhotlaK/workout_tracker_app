import 'package:flutter/material.dart';
import '../pages/settings_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'theme.dart'; // Your theme.dart

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = Settings.getValue<bool>(keyDarkMode, defaultValue: false) ?? false
      ? darkMode
      : lightMode;

  ThemeData get themeData => _themeData;

  // Optional: Add a getter for isDarkMode if UI needs to know
  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    final newIsDarkMode = !isDarkMode;
    if (newIsDarkMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    // Persist value for settings_page.dart
    Settings.setValue<bool>(keyDarkMode, newIsDarkMode);
    notifyListeners();
  }

  // Necessary to update themeProvider based on settings
  void loadThemeFromSettings() {
    final bool isDarkModeEnabled = Settings.getValue<bool>(keyDarkMode, defaultValue: false) ?? false;
    if (isDarkModeEnabled && _themeData != darkMode) {
      _themeData = darkMode;
      notifyListeners();
    } else if (!isDarkModeEnabled && _themeData != lightMode) {
      _themeData = lightMode;
      notifyListeners();
    }
  }
}