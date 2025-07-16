import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode(); // Load saved theme on initialization
  }

  // load _themeMode from shared preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedThemeMode = prefs.getString(_themeModeKey);

    if (savedThemeMode == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedThemeMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system; // Default or if no preference saved
    }
    notifyListeners();
  }

  // Update _themeMode universally
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return; // No change

    _themeMode = mode;
    notifyListeners();

    // Persist the choice
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_themeModeKey, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_themeModeKey, 'dark');
    } else {
      await prefs.remove(_themeModeKey); // Or set to 'system'
    }
  }

  // Helper to toggle between light and dark (ignoring system for direct toggle)
  Future<void> toggleTheme(bool isDarkMode) async {
    await setThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }
}