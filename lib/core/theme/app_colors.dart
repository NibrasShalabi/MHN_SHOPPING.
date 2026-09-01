import 'package:flutter/material.dart';

/// App color palette — use these instead of raw Color() values anywhere in the app.
///
/// Phoenix theme, red-weighted: black carries the screen and the fire is
/// built from deep crimson upward, not from orange downward. Orange only
/// appears at the very hot end of a gradient, the way an ember actually
/// glows — which is what keeps it reading as rich rather than as a plain
/// red app.
///
/// Three fire depths are defined (ember → crimson → scarlet → glow) so a
/// surface can be tuned by how "hot" it should look, instead of everything
/// sharing one flat tone.
class AppColors {
  AppColors._();

  // Surfaces — black with a red cast, so the fire sits in it, not on it
  static const Color surface = Color(0xFF0B0607); // page background
  static const Color surfaceWine = Color(0xFF1A0B0C); // app bar, nav bar
  static const Color surfaceElevated = Color(0xFF130A0B); // cards, sheets, inputs
  static const Color surfaceDark = Color(0xFF050303); // deepest layer / image wells
  static const Color border = Color(0xFF3D1A1C);

  // Fire ramp, coolest → hottest. Named so gradients read clearly.
  static const Color emberDeep = Color(0xFF4A0507); // dying coal
  static const Color ember = Color(0xFF7A0C10); // deep blood red
  static const Color crimson = Color(0xFFA81419); // core red
  static const Color scarlet = Color(0xFFD32020); // bright red
  static const Color flame = Color(0xFFE8471C); // red-orange edge
  static const Color glow = Color(0xFFF57A2B); // hottest tip, used sparingly

  // Primary — the crimson core carries the brand
  static const Color primary = crimson;
  static const Color primaryDark = ember;
  static const Color primaryLight = scarlet;

  // Gold — pulled red-warm so it belongs to the fire instead of sitting
  // apart from it. Highlight only: prices, badges, active tabs, loyalty.
  static const Color gold = Color(0xFFDE9A34);
  static const Color goldLight = Color(0xFFF3C978);
  static const Color goldDark = Color(0xFF7A4A10);

  // Accent — warm ash rose for softer emphasis
  static const Color accent = Color(0xFFC9524A);
  static const Color accentLight = Color(0xFFE7ACA3);

  // Text
  //
  // No pure white anywhere: on a near-black screen it glares and flattens
  // the palette. Headings carry gold, body copy is a warm light grey, and
  // supporting text steps down from there.
  static const Color textPrimary = Color(0xFFD5CCC9); // body copy
  static const Color textSecondary = Color(0xFF9C918D); // details, captions
  static const Color textOnPrimary = Color(0xFFE8E1DE); // over fire surfaces
  static const Color textDisabled = Color(0xFF6E6462);

  /// Headings. Kept as its own name so a heading colour change doesn't
  /// mean hunting through every text style.
  static const Color textHeading = gold;

  // Semantic — kept cool enough not to be mistaken for the fire ramp
  static const Color success = Color(0xFF4C9068);
  static const Color warning = Color(0xFFD9A03C);
  static const Color error = Color(0xFFE85A4A);
  static const Color info = Color(0xFF5390A8);

  /// Signature ramp for large branded surfaces (hero blocks, promo
  /// swiper). Four stops, weighted toward red: the orange only shows at
  /// the hot corner, so the surface reads as burning coal rather than as
  /// an orange panel.
  static const LinearGradient fireGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [flame, scarlet, crimson, ember],
    stops: [0.0, 0.3, 0.62, 1.0],
  );

  /// Wordmark gradient — yellow core through orange into red, the way a
  /// flame reads from its hottest point outward. Used by AppLogo only.
  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD24A), glow, flame, scarlet, ember],
    stops: [0.0, 0.28, 0.55, 0.8, 1.0],
  );

  /// Deeper variant for small blocks (category icon wells, badges) where
  /// the full ramp would look busy at that size.
  static const LinearGradient emberGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [scarlet, crimson, emberDeep],
  );
}