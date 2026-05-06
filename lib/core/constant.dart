import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors — Premium Light Warm Theme
  static const Color bg = Color(0xFFFDFCFB); // Refined off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color card = Color(0xFFFFFFFF); // White cards
  static const Color border = Color(0xFFF2EAE4); // Soft warm border

  static const Color accent = Color(0xFFF17A98); // Warm pink
  static const Color accentSecondary = Color(0xFFFFA066); // Warm orange
  static const Color accentTertiary = Color(0xFFFF9F7F); // Coral warm
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  static const Color text1 = Color(0xFF1A1A1A); // Near black
  static const Color text2 = Color(0xFF6B6B6B); // Medium grey
  static const Color text3 = Color(0xFFAFAFAF); // Light grey

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFF17A98), Color(0xFFFFA066)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFFDFCFB), Color(0xFFF5EFE9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentSecondary,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: text1,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.syne(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: text1,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.syne(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: text1,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text1,
        ),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: text1, height: 1.5),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: text2, height: 1.5),
        bodySmall: GoogleFonts.dmSans(fontSize: 12, color: text3),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: text1, size: 20),
        titleTextStyle: TextStyle(
          color: text1,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: text3),
      ),
    );
  }

  static ThemeData get darkTheme =>
      lightTheme; // For now, focus on perfect light theme
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
