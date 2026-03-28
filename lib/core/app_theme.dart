import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build() {
    const seedColor = Color(0xFF173A7A);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
          color: Color(0xFF102345),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF102345),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF1E355F),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFF4F6FA),
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFF173A7A),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: Color(0xFF102345),
        ),
        toolbarTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: Color(0xFF102345),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
