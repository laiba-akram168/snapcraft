import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors — Light Warm Theme
  static const Color bg = Color(0xFFFFFBF8); // Off-white warm
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color card = Color(0xFFFFF9F6); // Light warm cream
  static const Color border = Color(0xFFE8D4CC); // Light warm border

  static const Color accent = Color(0xFFF17A98); // Warm pink
  static const Color accentPurple = Color(0xFFFFA066); // Warm orange
  static const Color accentBlue = Color(0xFFFF9F7F); // Coral warm
  static const Color success = Color(0xFFF17A98); // Warm pink accent

  static const Color text1 = Color(0xFF1A1A1A); // Near black
  static const Color text2 = Color(0xFF4F4F4F); // Dark grey
  static const Color text3 = Color(0xFF8F8F8F); // Medium grey

  // Gradients — Modern dark blends
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFF17A98), Color(0xFFFFA066)], // warm pink → orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF17A98), Color(0xFFFF9F7F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFFFFBF8), Color(0xFFFFE8D4)], // off-white → warm cream
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentPurple,
        surface: surface,
        background: bg,
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: text1,
        onBackground: text1,
      ),
      textTheme:
          GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.syne(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: text1,
        ),
        displayMedium: GoogleFonts.syne(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: text1,
        ),
        titleLarge: GoogleFonts.syne(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: text1,
        ),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: text1),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: text2),
        bodySmall: GoogleFonts.dmSans(fontSize: 12, color: text2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: text1),
        titleTextStyle: TextStyle(
          color: text1,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: text3,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shadowColor: const Color(0xFF000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: text3),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 0.5),
    );
  }

  // Keep alias so existing references don't break
  static ThemeData get darkTheme => lightTheme;
}

class AppConstants {
  static const String socketUrl = 'https://your-ai-backend.com';
  static const String apiBaseUrl = 'https://your-api.com/v1';

  // Filter names
  static const List<String> filterNames = [
    'Original',
    'Sepia',
    'Vintage',
    'Cool',
    'Warm',
    'Mono',
    'Fade',
    'Chrome',
  ];

  // Collage layouts
  static const int maxCollageItems = 9;
}
