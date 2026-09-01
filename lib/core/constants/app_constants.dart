/// General app constants — adjust values per project.
class AppConstants {
  AppConstants._();

  static const String appName = 'M.H.N Shoping';
  static const int apiTimeoutSeconds = 30;

  // Spacing (design tokens — use these everywhere instead of raw numbers)
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48; // large section breaks (e.g. Home swiper → categories)

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusXl = 28; // bottom sheets, large product cards, hero images

  // Icon sizes — toolbar/inline icons
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;

  // Icon sizes — large illustrative icons (splash slides, empty states, confirmation screens)
  static const double iconXl = 64; // empty states, confirmation screens
  static const double iconXxl = 96; // splash / onboarding illustrations

  // Elevation
  static const double elevationSm = 2;
  static const double elevationMd = 6;
  static const double elevationLg = 12;

  // Buttons
  static const double buttonHeight = 52;

  // AppBar — taller than default to fit the two-line wordmark
  static const double appBarHeight = 84;

  // Accessibility — minimum tappable area regardless of text scaling
  static const double minTouchTarget = 48;

  // Borders
  static const double borderThin = 1;
  static const double borderThick = 2;

  // Grid / layout
  static const double productCardMinWidth = 165; // drives responsive grid column count
  static const double productCardMaxWidth = 200; // sliver grid: max card width before adding a column
  static const double cartThumbSize = 72; // cart line thumbnail
  static const double supplementThumbSize = 96; // supplement row thumbnail
  static const double colorSwatchSize = 28; // product colour dot
  static const double reviewCardHeight = 320; // review carousel card
  static const double goalCardMinWidth = 160; // about-page goal grid
  static const double goalCardHeight = 170; // about-page goal card
  static const double timelineDotSize = 22; // order status timeline marker
  static const double appBarBorderHeight = 2; // gold hairline under the app bar

  // Splash fire intro — long enough for the burn sweep to read, short
  // enough that it doesn't feel like a wait before the app opens.
  static const Duration splashIntroDuration = Duration(milliseconds: 3400);

  // How long a snackbar stays on screen before sliding back up
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const double categoryCardMinWidth = 150; // category grid column count
  static const double categoryCardAspectRatio = 0.85; // taller than wide, room for the label band
  // Pagination — how close to the bottom before the next page is fetched
  static const double loadMoreThreshold = 400;
  static const double swiperAspectRatio = 2.2; // width / height
}