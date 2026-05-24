import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const _storageKey = 'app_theme_mode';
  AppThemeMode _mode = AppThemeMode.lightBrand;
  bool _loaded = false;

  ThemeProvider() {
    _loadFromStorage();
  }

  AppThemeMode get mode => _mode;
  ThemeData get theme => AppTheme.themes[_mode]!;
  String get name => AppTheme.themeNames[_mode]!;
  bool get loaded => _loaded;

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null) {
      final match = AppThemeMode.values.where((m) => m.name == saved);
      if (match.isNotEmpty) {
        _mode = match.first;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }
}
