import 'package:cloud_firestore/cloud_firestore.dart';

/// Where images are read from and written to. Firestore stores bucket
/// paths (products/abc/1712_0.webp), so moving to a custom domain or
/// another provider is one edit of config/media — no app release.
/// Same class as the admin's; the full guide is mhn_admin/docs/media.md.
abstract final class MediaConfig {
  static String baseUrl = 'https://pub-2d134d4fdf6440c1b779696af1a07dfd.r2.dev';
  static String uploadUrl = 'https://mhn-media.nibras-shalabi0.workers.dev';

  /// One read at startup; the defaults above stand if it fails.
  static Future<void> load(FirebaseFirestore db) async {
    try {
      final d = (await db.collection('config').doc('media').get()).data();
      baseUrl = d?['baseUrl'] as String? ?? baseUrl;
      uploadUrl = d?['uploadUrl'] as String? ?? uploadUrl;
    } catch (_) {}
  }

  static bool _external(String path) => path.startsWith('http');

  static String url(String path) => _external(path) ? path : '$baseUrl/$path';

  /// The small copy uploaded next to every product image.
  static String thumbUrl(String path) =>
      _external(path) ? path : url(path.replaceFirst(RegExp(r'\.webp$'), '_thumb.webp'));
}
