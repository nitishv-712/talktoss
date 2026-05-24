import 'package:flutter/material.dart';

enum AppThemeMode { lightBrand, darkBrand, cosmicMint, aurora }

class AppTheme {
  static final themes = {
    AppThemeMode.lightBrand: _lightBrand,
    AppThemeMode.darkBrand: _darkBrand,
    AppThemeMode.cosmicMint: _cosmicMint,
    AppThemeMode.aurora: _aurora,
  };

  static const themeNames = {
    AppThemeMode.lightBrand: 'TalkToss Light',
    AppThemeMode.darkBrand: 'TalkToss Dark',
    AppThemeMode.cosmicMint: 'Cosmic Mint',
    AppThemeMode.aurora: 'Aurora',
  };

  static ThemeData get _lightBrand => _build(
    brightness: Brightness.light,
    primary: const Color(0xFF0066CC), // Deep premium blue matching logo
    secondary: const Color(0xFF09C199), // Teal green matching logo
    surface: const Color(0xFFF5F9FC), // Crisp light blue-slate
    onSurface: const Color(0xFF0F1E2C), // Deep navy-slate text
    surfaceContainerLow: const Color(0xFFEAF1F6),
    surfaceContainer: const Color(0xFFDFEAF0),
    outline: const Color(0xFF5D7182),
    outlineVariant: const Color(0xFFCCD7E0),
    error: const Color(0xFFD32F2F),
  );

  static ThemeData get _darkBrand => _build(
    brightness: Brightness.dark,
    primary: const Color(0xFF00A6FE), // Sky blue matching logo bubble
    secondary: const Color(0xFF5AEA89), // Mint green matching logo arrow
    surface: const Color(0xFF0B141C), // Deep navy-black surface
    onSurface: const Color(0xFFEAF4FC), // Ice-blue text
    surfaceContainerLow: const Color(0xFF142230),
    surfaceContainer: const Color(0xFF1E3144),
    outline: const Color(0xFF7E92A2),
    outlineVariant: const Color(0xFF2C3E50),
    error: const Color(0xFFE57373),
  );

  static ThemeData get _cosmicMint => _build(
    brightness: Brightness.dark,
    primary: const Color(0xFF5AEA89), // Mint green main
    secondary: const Color(0xFF00A6FE), // Sky blue secondary
    surface: const Color(0xFF071912), // Deep forest green-black
    onSurface: const Color(0xFFE0F7FA), // Soft mint text
    surfaceContainerLow: const Color(0xFF0D2C20),
    surfaceContainer: const Color(0xFF164433),
    outline: const Color(0xFF6B8A7E),
    outlineVariant: const Color(0xFF1D3B30),
    error: const Color(0xFFE57373),
  );

  static ThemeData get _aurora => _build(
    brightness: Brightness.light,
    primary: const Color(0xFF09C199), // Teal green main
    secondary: const Color(0xFF00A6FE), // Sky blue secondary
    surface: const Color(0xFFF2FCFA), // Mint-tinted white
    onSurface: const Color(0xFF0A2621), // Deep pine text
    surfaceContainerLow: const Color(0xFFE0FAF4),
    surfaceContainer: const Color(0xFFC7F3EA),
    outline: const Color(0xFF537C74),
    outlineVariant: const Color(0xFFBBE5DD),
    error: const Color(0xFFD32F2F),
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
          (s) => s.contains(WidgetState.selected) ? primary : outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.5)
              : outlineVariant,
        ),
      ),
      useMaterial3: true,
    );
  }
}
