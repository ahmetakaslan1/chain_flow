import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  final Box _settingsBox;
  late ThemeMode _themeMode;

  ThemeProvider() : _settingsBox = Hive.box('settings') {
    _themeMode = _loadThemeFromHive();
  }

  ThemeMode get themeMode => _themeMode;

  ThemeMode _loadThemeFromHive() {
    final String? theme = _settingsBox.get('themeMode');
    if (theme == 'dark') {
      return ThemeMode.dark;
    } else if (theme == 'light') {
      return ThemeMode.light;
    } else {
      return ThemeMode.light;
    }
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _settingsBox.put('themeMode', isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }
}
