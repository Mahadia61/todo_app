import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('theme_mode');
    if (savedMode != null) {
      if (savedMode == ThemeMode.light.toString()) _themeMode = ThemeMode.light;
      if (savedMode == ThemeMode.dark.toString()) _themeMode = ThemeMode.dark;
      if (savedMode == ThemeMode.system.toString()) _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }
}