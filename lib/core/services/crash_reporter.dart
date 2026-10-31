import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashes and unexpected errors from customers' phones, in Firebase
/// Console → Crashlytics. Off in debug (your own runs stay out of the
/// reports) and on web (Crashlytics has no web SDK).
abstract final class CrashReporter {
  static bool get _on => !kIsWeb;

  /// Right after Firebase.initializeApp: catches framework errors and
  /// anything thrown outside a try (async gaps included).
  static Future<void> init() async {
    if (!_on) return;
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// An error the app handled but didn't expect — logged, not fatal.
  static void record(Object error, [StackTrace? stack]) {
    if (_on) FirebaseCrashlytics.instance.recordError(error, stack ?? StackTrace.current);
  }

  /// Ties reports to the account (the uid only — no name or phone).
  static void setUser(String? uid) {
    if (_on) FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '');
  }
}
