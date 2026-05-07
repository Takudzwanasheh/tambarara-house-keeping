import 'package:flutter/material.dart';

class AppTheme{
  static const primary=Color(0xff1565C0);
  static const background=Color(0xfff5f7fa);

  static ThemeData get lighTheme => ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        ),
      ),
    ),
  );
}