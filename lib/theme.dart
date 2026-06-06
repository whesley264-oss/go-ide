import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFF252526);
  static const Color surfaceLight = Color(0xFF2D2D30);
  static const Color border = Color(0xFF3C3C3C);
  static const Color textPrimary = Color(0xFFD4D4D4);
  static const Color textSecondary = Color(0xFF808080);
  static const Color accent = Color(0xFF007ACC);
  static const Color accentGreen = Color(0xFF4EC9B0);
  static const Color accentYellow = Color(0xFFDCDCAA);
  static const Color accentOrange = Color(0xFFCE9178);
  static const Color accentBlue = Color(0xFF569CD6);
  static const Color accentPurple = Color(0xFFC586C0);
  static const Color error = Color(0xFFF44747);
  static const Color success = Color(0xFF4EC9B0);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: accent,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accentGreen,
      surface: surface,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      bodySmall: TextStyle(color: textSecondary),
    ),
    iconTheme: const IconThemeData(color: textSecondary),
    dividerColor: border,
  );
}
