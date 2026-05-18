import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.lightCosmic;

  AppThemeMode get mode => _mode;
  ThemeData get theme => AppTheme.themes[_mode]!;
  String get name => AppTheme.themeNames[_mode]!;

  void setTheme(AppThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
