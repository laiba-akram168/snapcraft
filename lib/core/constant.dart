import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors — Deep Dark Modern Theme
  static const Color bg = Color(0xFF0F0F1E); // Deep navy black
  static const Color surface = Color(0xFF1A1A2E); // Dark navy
  static const Color card = Color(0xFF16213E); // Darker blue-navy
  static const Color border = Color(0xFF0F3460); // Deep blue border

  static const Color accent = Color(0xFF00D4FF); // Cyan
  static const Color accentPurple = Color(0xFF7B61FF); // Vibrant purple
  static const Color accentBlue = Color(0xFF00B4DB); // Ocean blue
  static const Color success = Color(0xFF00D97D); // Bright green

  static const Color text1 = Color(0xFFFAFAFA); // Near white
  static const Color text2 = Color(0xFFB0B0B0); // Light grey
  static const Color text3 = Color(0xFF707070); // Medium grey

  // Gradients — Modern dark blends
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF7B61FF), Color(0xFF00D4FF)], // vibrant purple → cyan
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF00B4DB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E)], // deep navy → dark navy
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentPurple,
        surface: surface,
        background: bg,
        onPrimary: bg,
        onSecondary: bg,
        onSurface: text1,
        onBackground: text1,
      ),
      textTheme:
          GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
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
        fillColor: surface,
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
