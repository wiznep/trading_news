import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Theme mode - defaults to system
  ThemeMode _themeMode = ThemeMode.system;

  // Getter for theme mode
  ThemeMode get themeMode => _themeMode;

  // Key for storing theme preference
  static const String _themeModeKey = 'theme_mode';

  // Constructor - load saved theme preference
  ThemeProvider() {
    _loadThemePreference();
  }

  // Is dark mode currently active?
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    _saveThemePreference();
    notifyListeners();
  }

  // Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference();
    notifyListeners();
  }

  // Save theme preference to shared preferences
  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String themeModeString;

    switch (_themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }

    await prefs.setString(_themeModeKey, themeModeString);
  }

  // Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);

    if (themeModeString != null) {
      switch (themeModeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }

      notifyListeners();
    }
  }
}
