import 'package:flutter/material.dart';

enum AppThemeMode { lightCosmic, darkNebula, aurora, solarFlare }

class AppTheme {
  static final themes = {
    AppThemeMode.lightCosmic: _lightCosmic,
    AppThemeMode.darkNebula: _darkNebula,
    AppThemeMode.aurora: _aurora,
    AppThemeMode.solarFlare: _solarFlare,
  };

  static const themeNames = {
    AppThemeMode.lightCosmic: 'Light Cosmic',
    AppThemeMode.darkNebula: 'Dark Nebula',
    AppThemeMode.aurora: 'Aurora',
    AppThemeMode.solarFlare: 'Solar Flare',
  };

  static ThemeData get _lightCosmic => _build(
        brightness: Brightness.light,
        primary: const Color(0xFF630ED4),
        secondary: const Color(0xFF00687A),
        surface: const Color(0xFFF9F9FF),
        onSurface: const Color(0xFF141B2B),
        surfaceContainerLow: const Color(0xFFF1F3FF),
        surfaceContainer: const Color(0xFFE9EDFF),
        outline: const Color(0xFF7B7487),
        outlineVariant: const Color(0xFFCCC3D8),
        error: const Color(0xFFBA1A1A),
      );

  static ThemeData get _darkNebula => _build(
        brightness: Brightness.dark,
        primary: const Color(0xFFD2BBFF),
        secondary: const Color(0xFF4CD7F6),
        surface: const Color(0xFF141B2B),
        onSurface: const Color(0xFFEDF0FF),
        surfaceContainerLow: const Color(0xFF1E2535),
        surfaceContainer: const Color(0xFF293040),
        outline: const Color(0xFF9E97AA),
        outlineVariant: const Color(0xFF4A4455),
        error: const Color(0xFFFFB4AB),
      );

  static ThemeData get _aurora => _build(
        brightness: Brightness.light,
        primary: const Color(0xFF00687A),
        secondary: const Color(0xFF630ED4),
        surface: const Color(0xFFF0FFFE),
        onSurface: const Color(0xFF001F26),
        surfaceContainerLow: const Color(0xFFE0F8FB),
        surfaceContainer: const Color(0xFFB8EFF5),
        outline: const Color(0xFF4A7880),
        outlineVariant: const Color(0xFFB2CDD2),
        error: const Color(0xFFBA1A1A),
      );

  static ThemeData get _solarFlare => _build(
        brightness: Brightness.light,
        primary: const Color(0xFFE65100),
        secondary: const Color(0xFFFFB300),
        surface: const Color(0xFFFFFBF0),
        onSurface: const Color(0xFF1C1400),
        surfaceContainerLow: const Color(0xFFFFF3E0),
        surfaceContainer: const Color(0xFFFFE0B2),
        outline: const Color(0xFF8C6A00),
        outlineVariant: const Color(0xFFD4C08A),
        error: const Color(0xFFBA1A1A),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color onSurface,
    required Color surfaceContainerLow,
    required Color surfaceContainer,
    required Color outline,
    required Color outlineVariant,
    required Color error,
  }) {
    final cs = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      // Use extensions for extra colors
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      outline: outline,
      outlineVariant: outlineVariant,
    );

    return ThemeData(
      colorScheme: cs,
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: 0.8),
        foregroundColor: onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : outline),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary.withValues(alpha: 0.5) : outlineVariant),
      ),
      useMaterial3: true,
    );
  }
}
