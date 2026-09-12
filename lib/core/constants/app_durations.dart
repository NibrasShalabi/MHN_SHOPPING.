class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);   // micro-interactions, أزرار
  static const Duration normal = Duration(milliseconds: 350); // page transitions, hero
  static const Duration slow = Duration(milliseconds: 500);   // شاشات كبيرة/معقدة (نادراً)
  static const Duration swiperAutoPlay = Duration(seconds: 4); // home promo swiper
}