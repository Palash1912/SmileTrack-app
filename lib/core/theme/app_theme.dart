import 'package:flutter/material.dart';

enum AppThemeType { mint, blue, pink }

class AppTheme {
  AppTheme._();

  // ===================== COLORS ===================== //
  // Accent
  static const Color accentYellow = Color(0xFFFFC107);

  // Calendar / Status Colors
  static const Color calGreen = Color(0xFF4CAF50);
  static const Color calYellow = Color(0xFFFFC107);
  static const Color calRed = Color(0xFFE57373);
  static const Color calWhite = Color(0xFFFFFFFF);

  // Default (Mint)
  static const Color primaryMint = Color(0xFF00C896);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentBlue = Color(0xFF4ECDC4);

  // Blue Theme
  static const Color bluePrimary = Color(0xFF2979FF);
  static const Color blueAccent = Color(0xFF448AFF);
  static const Color blueSurface = Color(0xFFF0F4FF);
  static const Color blueCard = Color(0xFFE8F0FE);
  static const Color blueBorder = Color(0xFFBBCEF8);
  static const Color blueTextSecondary = Color(0xFF4A6080);

  // Pink Theme
  static const Color pinkPrimary = Color(0xFFE91E8C);
  static const Color pinkAccent = Color(0xFF7C4DFF);
  static const Color pinkSurface = Color(0xFFFFF0F7);
  static const Color pinkCard = Color(0xFFFCE4F3);
  static const Color pinkBorder = Color(0xFFF8BBD9);
  static const Color pinkTextSecondary = Color(0xFF7A4060);

  // Light Mode Base (Mint)
  static const Color lightBg = Color(0xFFF8FFFE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0FBF8);
  static const Color lightText = Color(0xFF1A2E2A);
  static const Color lightTextSecondary = Color(0xFF5C7A73);
  static const Color lightBorder = Color(0xFFDCF0EB);

  // Dark Mode Base
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF242424);
  static const Color darkBorder = Color(0xFF2E2E2E);
  static const Color darkText = Color(0xFFF0F0F0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // Dark Mint tinted
  static const Color darkMintBg = Color(0xFF091A14);
  static const Color darkMintSurface = Color(0xFF112219);
  static const Color darkMintCard = Color(0xFF172E22);
  static const Color darkMintBorder = Color(0xFF1F3D2E);

  // Dark Blue tinted
  static const Color darkBlueBg = Color(0xFF090F1A);
  static const Color darkBlueSurface = Color(0xFF0F1825);
  static const Color darkBlueCard = Color(0xFF152030);
  static const Color darkBlueBorder = Color(0xFF1C2E42);

  // Dark Pink tinted
  static const Color darkPinkBg = Color(0xFF1A0910);
  static const Color darkPinkSurface = Color(0xFF240F18);
  static const Color darkPinkCard = Color(0xFF2E1420);
  static const Color darkPinkBorder = Color(0xFF3D1A2A);

  // ===================== LIGHT THEME ===================== //

  static ThemeData lightTheme(AppThemeType type) {
    Color primary;
    Color secondary;
    Color bg;
    Color surface;
    Color card;
    Color border;
    Color text;
    Color textSecondary;

    switch (type) {
      case AppThemeType.blue:
        primary = bluePrimary;
        secondary = blueAccent;
        bg = blueSurface;
        surface = lightSurface;
        card = blueCard;
        border = blueBorder;
        text = const Color(0xFF0D1B2A);
        textSecondary = blueTextSecondary;
        break;

      case AppThemeType.pink:
        primary = pinkPrimary;
        secondary = pinkAccent;
        bg = pinkSurface;
        surface = lightSurface;
        card = pinkCard;
        border = pinkBorder;
        text = const Color(0xFF1A0A12);
        textSecondary = pinkTextSecondary;
        break;

      case AppThemeType.mint:
      default:
        primary = primaryMint;
        secondary = accentCoral;
        bg = lightBg;
        surface = lightSurface;
        card = lightCard;
        border = lightBorder;
        text = lightText;
        textSecondary = lightTextSecondary;
    }

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      bg: bg,
      surface: surface,
      card: card,
      border: border,
      text: text,
      textSecondary: textSecondary,
    );
  }

  // ===================== DARK THEME ===================== //

  static ThemeData darkTheme(AppThemeType type) {
    Color primary;
    Color secondary;
    Color bg;
    Color surface;
    Color card;
    Color border;

    switch (type) {
      case AppThemeType.blue:
        primary = const Color(0xFF5B9BFF); // slightly lighter for dark bg
        secondary = const Color(0xFF82B1FF);
        bg = darkBlueBg;
        surface = darkBlueSurface;
        card = darkBlueCard;
        border = darkBlueBorder;
        break;

      case AppThemeType.pink:
        primary = const Color(0xFFFF4DB8); // slightly lighter for dark bg
        secondary = const Color(0xFFAB82FF);
        bg = darkPinkBg;
        surface = darkPinkSurface;
        card = darkPinkCard;
        border = darkPinkBorder;
        break;

      case AppThemeType.mint:
      default:
        primary = const Color(0xFF00E5A8); // slightly lighter for dark bg
        secondary = const Color(0xFFFF8A80);
        bg = darkMintBg;
        surface = darkMintSurface;
        card = darkMintCard;
        border = darkMintBorder;
    }

    return _buildTheme(
      brightness: Brightness.dark,
      primary: primary,
      secondary: secondary,
      bg: bg,
      surface: surface,
      card: card,
      border: border,
      text: darkText,
      textSecondary: darkTextSecondary,
    );
  }

  // ===================== SHARED BUILDER ===================== //

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color bg,
    required Color surface,
    required Color card,
    required Color border,
    required Color text,
    required Color textSecondary,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Nunito',

      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primary,
              secondary: secondary,
              tertiary: accentBlue,
              surface: surface,
              onPrimary: Colors.white,
              onSurface: text,
              outline: border,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: secondary,
              tertiary: accentBlue,
              surface: surface,
              // ignore: deprecated_member_use
              background: bg,
              onPrimary: Colors.white,
              onSurface: text,
              outline: border,
            ),

      scaffoldBackgroundColor: bg,

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Sora',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentCoral, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontFamily: 'Nunito',
        ),
        hintStyle: TextStyle(
          color: textSecondary.withOpacity(0.6),
          fontFamily: 'Nunito',
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w800,
            color: text,
            fontSize: 32),
        displayMedium: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            color: text,
            fontSize: 26),
        displaySmall: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            color: text,
            fontSize: 22),
        headlineLarge: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            color: text,
            fontSize: 20),
        headlineMedium: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
            color: text,
            fontSize: 18),
        bodyLarge: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            color: text,
            fontSize: 16),
        bodyMedium: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w400,
            color: textSecondary,
            fontSize: 14),
        labelLarge: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            color: text,
            fontSize: 14),
      ),
    );
  }
}