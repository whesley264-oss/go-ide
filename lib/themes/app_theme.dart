import 'package:flutter/material.dart';

class AppTheme {
  // Editor colors (VSCode dark+)
  static const Color editorBg = Color(0xFF1E1E1E);
  static const Color sidebarBg = Color(0xFF252526);
  static const Color panelBg = Color(0xFF333333);
  static const Color statusBarBg = Color(0xFF007ACC);
  
  // Syntax colors
  static const Color keyword = Color(0xFF569CD6);
  static const Color string = Color(0xFFCE9178);
  static const Color function = Color(0xFFDCDCAA);
  static const Color comment = Color(0xFF6A9955);
  static const Color variable = Color(0xFF9CDCFE);
  static const Color number = Color(0xFFB5CEA8);
  static const Color operator = Color(0xFFD4D4D4);
  static const Color type = Color(0xFF4EC9B0);
  static const Color lineNumber = Color(0xFF858585);
  static const Color selection = Color(0xFF264F78);
  static const Color cursor = Color(0xFFAEAFAD);
  
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: editorBg,
    primaryColor: const Color(0xFF0E639C),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0E639C),
      surface: editorBg,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: sidebarBg,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white54),
    ),
    dividerColor: Colors.white12,
    focusColor: const Color(0xFF0E639C),
    hoverColor: Colors.white10,
  );
}
