import 'package:shared_preferences/shared_preferences.dart';

/// Shared Preferences Service — نقطة وصول مركزية لكل SharedPreferences
/// كل الـ keys محددة هنا — لا أحد يكتب string مباشرة في الكود
/// المسار: lib/core/services/shared_prefs_service.dart
class SharedPrefsService {
  static SharedPreferences? _prefs;

  /// يُستدعى مرة واحدة في main() قبل runApp
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _i {
    assert(_prefs != null, 'SharedPrefsService.init() لازم تُستدعى أول شي في main()');
    return _prefs!;
  }

  // ===== Keys =====
  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kLastEmail      = 'last_email';
  static const _kThemeMode      = 'theme_mode';
  static const _kLanguage       = 'language';
  static const _kSeenNewProducts = 'seen_new_products';
  static const _kDealsSeenAt     = 'deals_seen_at';

  // ===== Onboarding =====

  /// هل شاف المستخدم الـ onboarding من قبل؟
  static bool get onboardingSeen => _i.getBool(_kOnboardingSeen) ?? false;
  static Future<void> setOnboardingSeen() => _i.setBool(_kOnboardingSeen, true);

  // ===== Auth =====

  /// آخر إيميل استخدمه المستخدم — يُملأ تلقائياً في login field
  static String? get lastEmail => _i.getString(_kLastEmail);
  static Future<void> setLastEmail(String email) => _i.setString(_kLastEmail, email);
  static Future<void> clearLastEmail() => _i.remove(_kLastEmail);

  // ===== Theme =====

  /// light / dark / system
  static String get themeMode => _i.getString(_kThemeMode) ?? 'system';
  static Future<void> setThemeMode(String mode) => _i.setString(_kThemeMode, mode);

  // ===== Language =====

  /// ar / en
  static String get language => _i.getString(_kLanguage) ?? 'ar';
  static Future<void> setLanguage(String lang) => _i.setString(_kLanguage, lang);

  // ===== New-product badge =====

  /// Products whose "جديد" badge this device has already shown.
  static List<String> get seenNewProducts => _i.getStringList(_kSeenNewProducts) ?? const [];
  static Future<void> setSeenNewProducts(List<String> ids) => _i.setStringList(_kSeenNewProducts, ids);

  // ===== Fire deals badge =====

  /// When this device last opened fire deals — newer deals light the "جديد" dot.
  static DateTime? get dealsSeenAt {
    final ms = _i.getInt(_kDealsSeenAt);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> setDealsSeenAt(DateTime at) => _i.setInt(_kDealsSeenAt, at.millisecondsSinceEpoch);

  // ===== Clear All (logout) =====

  /// امسح كل البيانات عند تسجيل الخروج
  /// onboarding_seen يبقى — المستخدم ما يشوفه مرة ثانية
  static Future<void> clearOnLogout() async {
    await _i.remove(_kLastEmail);
    // أضيف أي key مستقبلي هنا
  }
}