import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateNeed { none, optional, required }

/// config/app, edited from the admin's "تحديث التطبيق" section.
class AppUpdateInfo {
  final int latestBuild;
  final int minBuild;
  final String latestName;
  final String notes;
  final String storeUrl;

  const AppUpdateInfo({
    required this.latestBuild,
    required this.minBuild,
    required this.latestName,
    required this.notes,
    required this.storeUrl,
  });

  factory AppUpdateInfo.fromMap(Map<String, dynamic> m) => AppUpdateInfo(
        latestBuild: (m['latestBuild'] as num? ?? 0).toInt(),
        minBuild: (m['minBuild'] as num? ?? 0).toInt(),
        latestName: m['latestName'] as String? ?? '',
        notes: m['notes'] as String? ?? '',
        storeUrl: m['storeUrl'] as String? ?? '',
      );

  UpdateNeed needFor(int build) => build < minBuild
      ? UpdateNeed.required
      : build < latestBuild
          ? UpdateNeed.optional
          : UpdateNeed.none;
}

/// One read per launch. Never blocks the app on failure: no network or no
/// document simply means no prompt.
class AppUpdateRepository {
  final FirebaseFirestore _db;

  AppUpdateRepository(this._db);

  /// The installed build — the `+N` of pubspec's `version`.
  ///
  /// `flutter build apk --split-per-abi` adds 1000 × the ABI to Android's
  /// versionCode (arm64 build 1 installs as 2001), so only the last three
  /// digits are the build. Builds therefore stay below 1000.
  Future<int> installedBuild() async =>
      (int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0) % 1000;

  Future<AppUpdateInfo?> fetch() async {
    try {
      final doc = await _db.collection('config').doc('app').get();
      return doc.exists ? AppUpdateInfo.fromMap(doc.data()!) : null;
    } catch (_) {
      return null;
    }
  }
}
