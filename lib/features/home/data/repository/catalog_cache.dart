import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/promo_banner.dart';

/// In-memory cache for catalog data.
///
/// The catalog changes roughly once a week, so re-reading it on every
/// screen open or filter tap would burn Firestore reads for nothing. Each
/// entry carries a timestamp and is served straight from memory until it
/// goes stale.
///
/// Scope is the app session (cleared on restart). A disk-backed layer can
/// sit behind this later without changing any caller.
class CatalogCache {
  /// Categories/banners barely change — a long window is safe here.
  static const Duration structureTtl = Duration(hours: 6);

  /// Product pages: shorter, so a price edit surfaces the same day without
  /// the user having to reinstall anything.
  static const Duration productsTtl = Duration(minutes: 30);

  final Map<String, _CacheEntry<Object>> _entries = {};

  T? read<T>(String key, Duration ttl) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.storedAt) > ttl) {
      _entries.remove(key);
      return null;
    }
    return entry.value as T;
  }

  void write<T extends Object>(String key, T value) {
    _entries[key] = _CacheEntry(value: value, storedAt: DateTime.now());
  }

  /// Called after the admin changes something, or on pull-to-refresh.
  void invalidateAll() => _entries.clear();

  void invalidateCategory(String categoryId) {
    _entries.removeWhere((key, _) => key.startsWith('products:$categoryId'));
  }

  // Key builders — kept here so callers never hand-format a key string.
  /// Scoped so the store grid and the fitness shelf don't overwrite each
  /// other's cached list.
  static String categoriesKey(CatalogScope scope) => 'categories:${scope.name}';
  static const String bannersKey = 'banners';

  static String categoryKey(String categoryId) => 'category:$categoryId';

  static String productKey(String productId) => 'product:$productId';

  static String productsKey({
    required String categoryId,
    String? filterId,
    String? cursor,
  }) =>
      'products:$categoryId:${filterId ?? 'all'}:${cursor ?? 'first'}';
}

class _CacheEntry<T> {
  final T value;
  final DateTime storedAt;

  const _CacheEntry({required this.value, required this.storedAt});
}

/// Convenience aliases so call sites read clearly.
typedef CachedCategories = List<Category>;
typedef CachedBanners = List<PromoBanner>;
typedef CachedProducts = List<Product>;