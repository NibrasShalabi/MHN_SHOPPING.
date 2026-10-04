import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text styles — use these instead of raw TextStyle anywhere in the app.
/// Uses the bundled Tajawal font (assets/fonts/) — no network dependency.
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Tajawal';

  /// Display face for the brand wordmark only — a signature script reads
  /// as a logo, not as body copy, so it never leaves the logo. Everything
  /// else stays on Tajawal for legibility.
  static const String _logoFontFamily = 'GreatVibes';

  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeading,
    letterSpacing: 0.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ==================== الشعار ====================

  /// Wordmark, standard size — app bars.
  ///
  /// The colour here is a fallback: AppLogo paints the wordmark through a
  /// fire gradient, which replaces it.
  static const TextStyle logo = TextStyle(
    fontFamily: _logoFontFamily,
    fontSize: 34,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  /// Wordmark, oversized — splash and hero blocks.
  static const TextStyle logoLarge = TextStyle(
    fontFamily: _logoFontFamily,
    fontSize: 62,
    color: AppColors.textPrimary,
    height: 1.05,
  );

  /// The second line ("shoping") — smaller, gold, sits under the mark.
  static const TextStyle logoSub = TextStyle(
    fontFamily: _logoFontFamily,
    fontSize: 22,
    color: AppColors.goldLight,
    height: 1.0,
  );

  static const TextStyle logoSubLarge = TextStyle(
    fontFamily: _logoFontFamily,
    fontSize: 36,
    color: AppColors.goldLight,
    height: 1.1,
  );
}