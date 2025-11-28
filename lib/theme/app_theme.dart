// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:zbeub_task_plan/data/enums.dart';

class AppTheme {
  // 1. Define core colors and constants
  // This is your main brand color
  static const Color primarySeedColor = Color.fromARGB(255, 30, 150, 190);
  static const double cardBorderRadius = 12.0;

  static const Color urgentImportantColor = Color.fromARGB(255, 206, 38, 16);
  static const Color importantNotUrgentColor = Color.fromARGB(
    255,
    230,
    204,
    62,
  );
  // Note: Colors.orange.shade600 corresponds to ARGB(255, 255, 140, 0)
  static const Color urgentNotImportantColor = Color.fromARGB(
    255,
    218,
    125,
    13,
  );
  static const Color notUrgentNotImportantColor = Color.fromARGB(
    255,
    135,
    172,
    34,
  );

  static const Color professionalCategoryColor = Color.fromARGB(
    255,
    245,
    197,
    217,
  );
  static const Color personalCategoryColor = Color.fromARGB(255, 192, 226, 112);

  static const Color deleteButtonColor = Colors.grey;
  static const Color unarchiveButtonColor = Colors.blueGrey;

  static Color getQuadrantColor({
    required ImportanceLevel importance,
    required UrgencyLevel urgency,
  }) {
    if (importance == ImportanceLevel.important &&
        urgency == UrgencyLevel.urgent) {
      return urgentImportantColor;
    } else if (importance == ImportanceLevel.important &&
        urgency == UrgencyLevel.notUrgent) {
      return importantNotUrgentColor;
    } else if (importance == ImportanceLevel.notImportant &&
        urgency == UrgencyLevel.urgent) {
      return urgentNotImportantColor;
    } else {
      // Implicitly: Not Important and Not Urgent
      return notUrgentNotImportantColor;
    }
  }

  static Color getCategoryColor(TasksCategories category) {
    switch (category) {
      case TasksCategories.professional:
        return professionalCategoryColor;
      case TasksCategories.personal:
        return personalCategoryColor;
    }
  }

  // =========================================================================
  // LIGHT THEME (EXISTING)
  // =========================================================================
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      // The ColorScheme derives all color roles (secondary, tertiary, background, etc.)
      // from a single seed color, ensuring harmony.
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 67, 22, 172),
        primary: const Color.fromARGB(255, 83, 47, 14),
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
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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

  // =========================================================================
  // DARK THEME (NEW)
  // =========================================================================
  static ThemeData get darkTheme {
    // A slightly lighter black for a "lighted dark" effect
    const Color darkBackground = Color.fromARGB(255, 18, 18, 18);
    // Maintain the existing primary/secondary colors but optimized for dark mode
    const Color darkPrimary = Color.fromARGB(
      255,
      160,
      100,
      60,
    ); // Lighter version of 83, 47, 14 for visibility
    const Color darkSecondary = Color.fromARGB(
      255,
      255,
      100,
      130,
    ); // Lighter version of 218, 3, 56 for visibility

    final baseTheme = ThemeData(
      // Use the standard dark mode for the base
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 67, 22, 172),
        primary: darkPrimary, // Use the adjusted primary color
        secondary: darkSecondary, // Use the adjusted secondary color
        brightness: Brightness.dark,
        surface: darkBackground,
        background: darkBackground,
        onSurface: Colors.white70,
        onBackground: Colors.white,
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
    );

    return baseTheme.copyWith(
      // --- Global Widget Styling ---

      // 1. AppBar Styling
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground, // Dark AppBar
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),

      // 2. ElevatedButton Styling (maintains the logic but uses dark-friendly colors)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: darkPrimary, // Uses the darkPrimary
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // 3. Card Styling
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        margin: const EdgeInsets.all(8.0),
        color: const Color.fromARGB(
          255,
          30,
          30,
          30,
        ), // Slightly lighter card surface
      ),

      // 4. Input Field Styling
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkPrimary.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkPrimary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: darkPrimary.withOpacity(0.05),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),

      // 5. Floating Action Button Styling
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkSecondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }
}
