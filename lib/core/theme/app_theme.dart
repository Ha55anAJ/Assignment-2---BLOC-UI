import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/items/domain/entities/item.dart';

/// The colors used across the app.
abstract final class AppColors {
  /// The page background: a very light, slightly violet grey.
  static const Color canvas = Color(0xFFF6F3F7);

  /// The background of cards and other raised surfaces.
  static const Color surface = Colors.white;

  /// The main text color.
  static const Color ink = Color(0xFF1F1B24);

  /// Secondary text, such as locations and timestamps.
  static const Color muted = Color(0xFF6B6573);

  /// Thin borders and dividers.
  static const Color hairline = Color(0xFFE8E3EC);

  /// The IBA brand color, used for actions and selected chips.
  static const Color maroon = Color(0xFF8B1E3F);
}

/// A background and foreground color pair, used for badges and icon tiles.
class TintPair {
  /// Creates a pair of a soft [background] and a strong [foreground].
  const TintPair(this.background, this.foreground);

  /// The soft tint behind the content.
  final Color background;

  /// The strong color used for text and icons on top of [background].
  final Color foreground;
}

/// The colors of the Lost / Found / Claimed badges.
abstract final class StatusColors {
  /// Warm orange: someone is still looking for this.
  static const TintPair lost = TintPair(Color(0xFFFDE8D7), Color(0xFFB4490C));

  /// Green: the item is safe and waiting for its owner.
  static const TintPair found = TintPair(Color(0xFFDDF2E3), Color(0xFF1F7A45));

  /// Quiet slate: the story is over.
  static const TintPair claimed = TintPair(
    Color(0xFFE7E5EE),
    Color(0xFF55506A),
  );

  /// Returns the colors for [status].
  static TintPair of(ItemStatus status) {
    return switch (status) {
      ItemStatus.lost => lost,
      ItemStatus.found => found,
      ItemStatus.claimed => claimed,
    };
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

    final textTheme = GoogleFonts.hankenGroteskTextTheme().apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.hairline),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: serif(fontSize: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.maroon, width: 1.6),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.muted.withValues(alpha: 0.7),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.maroon,
        side: const BorderSide(color: AppColors.hairline),
        shape: const StadiumBorder(),
        showCheckmark: false,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        extendedTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
