import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors — Soft Pastel Light Theme
  static const Color bg = Color(0xFFFBF7F4); // warm cream white
  static const Color surface = Color(0xFFF5EFF8); // very light lavender blush
  static const Color card = Color(0xFFFFFFFF); // pure white cards
  static const Color border = Color(0x22B0A0C8); // soft lavender border

  static const Color accent = Color(0xFFB388FF); // pastel lavender
  static const Color accentPurple = Color(0xFFF48FB1); // pastel rose/pink
  static const Color accentBlue = Color(0xFF81D4FA); // pastel sky blue
  static const Color success = Color(0xFFA5D6A7); // pastel mint green

  static const Color text1 = Color(0xFF3D2F4A); // deep soft plum (readable)
  static const Color text2 = Color(0xFF7B6B8D); // muted lavender-grey
  static const Color text3 = Color(0xFFBAADCC); // light muted lilac

  // Gradients — soft pastel blends
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFCE93D8), Color(0xFFF48FB1)], // pastel purple → rose
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFB388FF), Color(0xFF81D4FA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFFBF7F4), Color(0xFFF0EAF8)], // cream → lavender blush
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
        onPrimary: Colors.white,
        onSecondary: Colors.white,
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
        backgroundColor: bg,
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
        backgroundColor: card,
        selectedItemColor: accent,
        unselectedItemColor: text3,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shadowColor: const Color(0x22B0A0C8),
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
