import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color primaryColor = Color(0xFF2F3EAA);
  static const Color secondaryColor = Color(0xFFFF554B);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  static const Color subtitleColor = Color(0xFF757575);
  static const Color cardColor = Colors.white;

  // Dark theme colors (updated to dark blue)
  static const Color darkPrimaryColor = Color(0xFF4F68FF); // Brighter blue
  static const Color darkSecondaryColor = Color(0xFFFF5252);
  static const Color darkBackgroundColor = Color(0xFF0A1334); // Dark blue
  static const Color darkSurfaceColor =
      Color(0xFF142045); // Slightly lighter dark blue
  static const Color darkTextColor = Colors.white;
  static const Color darkSubtitleColor =
      Color(0xFFDDDDDD); // Light gray for subtitles
  static const Color darkCardColor =
      Color(0xFF192552); // Even lighter dark blue for cards

  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: subtitleColor,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardColor,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkSurfaceColor, // Updated to slightly lighter blue
        foregroundColor: darkTextColor,
        titleTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: darkTextColor),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkTextColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkTextColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: darkSubtitleColor,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: darkPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: darkCardColor,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        brightness: Brightness.dark,
        background: darkBackgroundColor,
        surface: darkSurfaceColor,
        onSurface: darkTextColor,
      ),
      dividerColor: Colors.white24,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBackgroundColor,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: darkTextColor.withOpacity(0.6),
      ),
    );
  }
}
