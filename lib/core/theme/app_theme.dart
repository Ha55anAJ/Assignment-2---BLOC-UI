import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The colors used across the app.
abstract final class AppColors {
  /// The page background: a very light, slightly violet grey.
  static const Color canvas = Color(0xFFF6F3F7);

  /// The background of cards and other raised surfaces.
  static const Color surface = Colors.white;

  /// The main text color.
  static const Color ink = Color(0xFF1F1B24);

  /// Secondary text, such as post previews.
  static const Color muted = Color(0xFF6B6573);

  /// Thin borders and dividers.
  static const Color hairline = Color(0xFFE8E3EC);

  /// The brand color, used for actions and the refresh indicator.
  static const Color maroon = Color(0xFF8B1E3F);
}

/// A background and foreground color pair that identifies one author.
class AuthorColors {
  const AuthorColors(this.background, this.foreground);

  /// The soft tint behind the author's avatar.
  final Color background;

  /// The strong color used for the avatar's number.
  final Color foreground;

  static const List<AuthorColors> _palette = [
    AuthorColors(Color(0xFFFBE4EA), Color(0xFF9B1D45)),
    AuthorColors(Color(0xFFFDEFD2), Color(0xFF8A5300)),
    AuthorColors(Color(0xFFE3F1DA), Color(0xFF3F6B1E)),
    AuthorColors(Color(0xFFD9F0EE), Color(0xFF126B66)),
    AuthorColors(Color(0xFFDEE9FB), Color(0xFF1F4FA3)),
    AuthorColors(Color(0xFFE8E0FA), Color(0xFF5B3BB0)),
    AuthorColors(Color(0xFFF8DFF1), Color(0xFF9A2A80)),
    AuthorColors(Color(0xFFE4E7EC), Color(0xFF3A4556)),
    AuthorColors(Color(0xFFFDE3D6), Color(0xFFA8430F)),
    AuthorColors(Color(0xFFD8EFF8), Color(0xFF0F6483)),
  ];

  /// Returns the same colors every time for the same [userId].
  static AuthorColors of(int userId) {
    return _palette[(userId - 1) % _palette.length];
  }
}

/// The app's typography and [ThemeData].
abstract final class AppTheme {
  /// Text style for headlines, set in a serif face.
  static TextStyle serif({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
    double height = 1.2,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// The theme for the whole app.
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.maroon,
      primary: AppColors.maroon,
      surface: AppColors.canvas,
      onSurface: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: GoogleFonts.hankenGroteskTextTheme().apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
