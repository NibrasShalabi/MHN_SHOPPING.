import 'shared_prefs_service.dart';

/// Tracks which "new" products the user has already seen, so the جديد
/// badge shows on the first visit and stops following them afterwards.
abstract class SeenProductsStore {
  bool hasSeen(String productId);

  Future<void> markSeen(Iterable<String> productIds);
}

/// Persisted across restarts — an in-memory set made every product look
/// new again each time the app opened.
class PrefsSeenProductsStore implements SeenProductsStore {
  /// Old ids rotate out; products stop being "new" long before this fills.
  static const int _maxTracked = 500;

  final Set<String> _seen = SharedPrefsService.seenNewProducts.toSet();

  @override
  bool hasSeen(String productId) => _seen.contains(productId);

  @override
  Future<void> markSeen(Iterable<String> productIds) async {
    final fresh = productIds.where(_seen.add).toList();
    if (fresh.isEmpty) return;
    final all = _seen.toList();
    final kept = all.length > _maxTracked ? all.sublist(all.length - _maxTracked) : all;
    await SharedPrefsService.setSeenNewProducts(kept);
  }
}
