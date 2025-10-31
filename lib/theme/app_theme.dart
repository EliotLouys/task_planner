import 'package:flutter/material.dart';

class AppTheme {
  // 1. Define core colors and constants
  // This is your main brand color
  static const Color primarySeedColor = Color.fromARGB(255, 30, 150, 190);
  static const double cardBorderRadius = 12.0;

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      // The ColorScheme derives all color roles (secondary, tertiary, background, etc.) 
      // from a single seed color, ensuring harmony.
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 67, 22, 172),
        primary: const Color.fromARGB(255, 183, 142, 236),
        secondary: const Color.fromARGB(255, 218, 3, 56),
        surface: Colors.white,
      ),
      useMaterial3: true,
      fontFamily: 'Inter', 
    );

    return baseTheme.copyWith(
      // --- Global Widget Styling ---

      // 1. AppBar Styling (Applies to all AppBars)
      appBarTheme: AppBarTheme(
        backgroundColor: baseTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),

      // 2. ElevatedButton Styling (Applies to the Home Page buttons and the Form submit button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // Global size constraint for main buttons (Home Page)
          minimumSize: const Size(200, 50), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: baseTheme.colorScheme.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      // 3. Card Styling (Applies to Selection Page cards and Task List cards)
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        margin: const EdgeInsets.all(8.0), // Consistent margin around all cards
      ),

      // 4. Input Field Styling (Applies to TextFormFields in the modal)
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primarySeedColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primarySeedColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primarySeedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: primarySeedColor.withOpacity(0.05),
      ),

      // 5. Floating Action Button Styling
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: baseTheme.colorScheme.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }
}
