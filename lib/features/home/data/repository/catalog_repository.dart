import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variants.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_page_result.dart';
import '../../domain/entities/promo_banner.dart';
import 'catalog_cache.dart';

/// Contract for catalog data (categories, filters, products, banners).
///
/// Products are paginated: categories are expected to hold thousands of
/// items, so nothing here ever returns a full category at once.
abstract class CatalogRepository {
  Future<List<PromoBanner>> getPromoBanners({bool forceRefresh = false});

  /// [scope] picks which section's categories to return — the store grid
  /// and the fitness shelf both go through here.
  Future<List<Category>> getCategories({
    CatalogScope scope = CatalogScope.store,
    bool forceRefresh = false,
  });

  Future<Category> getCategory(String categoryId, {bool forceRefresh = false});

  Future<Product> getProduct(String productId, {bool forceRefresh = false});

  /// [filterId] null means "all products in this category".
  /// [cursor] null fetches the first page; pass the previous result's
  /// nextCursor to continue.
  Future<ProductPageResult> getProducts({
    required String categoryId,
    String? filterId,
    String? cursor,
    bool forceRefresh = false,
  });
}

/// UI-phase implementation. Generates a large fake catalog so pagination
/// and caching are exercised for real rather than looking correct against
/// six hardcoded rows.
///
/// NOTE(logic-phase): the Firestore version needs a composite index on
/// (categoryId, filterId, createdAt) — without it these queries fail at
/// runtime, and the index has to be created once in the Firebase console.
class FakeCatalogRepository implements CatalogRepository {
  static const int pageSize = 24;

  final CatalogCache _cache;

  FakeCatalogRepository(this._cache);

  static const List<Category> _categories = [
    // Store.
    Category(
      id: 'hair',
      name: 'شعر',
      filters: [
        ProductFilter(id: 'serum', name: 'سيروم'),
        ProductFilter(id: 'oils', name: 'زيوت'),
        ProductFilter(id: 'shampoo', name: 'شامبو'),
      ],
    ),
    Category(
      id: 'skin',
      name: 'بشرة',
      filters: [
        ProductFilter(id: 'cream', name: 'كريمات'),
        ProductFilter(id: 'cleanser', name: 'غسول'),
      ],
    ),

    // Fitness — same structure, so a new shelf (energy drinks, gear) is a
    // data entry rather than a new screen.
    Category(
      id: 'supplements',
      name: 'مكمّلات ومشروبات',
      scope: CatalogScope.fitness,
      filters: [
        ProductFilter(id: 'protein', name: 'بروتين'),
        ProductFilter(id: 'minerals', name: 'أملاح ومعادن'),
        ProductFilter(id: 'energy', name: 'طاقة'),
      ],
    ),
    Category(
      id: 'gear',
      name: 'مستلزمات رياضية',
      scope: CatalogScope.fitness,
      filters: [
        ProductFilter(id: 'bands', name: 'باندات'),
        ProductFilter(id: 'supports', name: 'مشدّات'),
        ProductFilter(id: 'patches', name: 'لاصقات'),
      ],
    ),
    Category(
      id: 'slimming',
      name: 'مستحضرات تنحيف',
      scope: CatalogScope.fitness,
      filters: [],
    ),

    // Loyalty store — one category, priced in points.
    Category(
      id: 'loyalty',
      name: 'متجر الولاء',
      scope: CatalogScope.loyalty,
      filters: [],
    ),
  ];

  /// Stands in for the Firestore collection.
  static const List<ClothingSize> _sampleSizes = [
    ClothingSize.s,
    ClothingSize.m,
    ClothingSize.l,
    ClothingSize.xl,
  ];

  static const List<ProductColor> _sampleColors = [
    ProductColor(name: 'أسود', value: 0xFF1A1A1A),
    ProductColor(name: 'أبيض', value: 0xFFF5F5F5),
    ProductColor(name: 'خمري', value: 0xFF7A0C10),
    ProductColor(name: 'بيج', value: 0xFFD8C3A5),
  ];

  static const List<SizeGuideRow> _sampleSizeGuide = [
    SizeGuideRow(size: 'S', measurements: {'الصدر': '88 سم', 'الطول': '64 سم'}),
    SizeGuideRow(size: 'M', measurements: {'الصدر': '96 سم', 'الطول': '66 سم'}),
    SizeGuideRow(size: 'L', measurements: {'الصدر': '104 سم', 'الطول': '68 سم'}),
    SizeGuideRow(size: 'XL', measurements: {'الصدر': '112 سم', 'الطول': '70 سم'}),
  ];

  static final List<Product> _allProducts = _generateProducts();

  static List<Product> _generateProducts() {
    final products = <Product>[];

    // Fitness items carry no price: they're prescribed, not ordered.
    for (final category in _categories.where((c) => c.scope == CatalogScope.fitness)) {
      final filters = category.filters.isEmpty
          ? [const ProductFilter(id: '', name: '')]
          : category.filters;

      for (final filter in filters) {
        for (var i = 1; i <= 6; i++) {
          products.add(Product(
            id: '${category.id}_${filter.id}_$i',
            categoryId: category.id,
            filterId: filter.id.isEmpty ? null : filter.id,
            name: filter.name.isEmpty ? '${category.name} $i' : '${filter.name} $i',
            imageUrls: const ['', '', ''],
            price: 20000 + (i * 3500),
            // Priced but not orderable: the specialist prescribes it.
            isOrderable: false,
            stock: 10,
            description: 'يُحدَّد استخدامه ومقداره من قبل المختص المشرف على القسم.',
            ingredients: 'تُذكر المكوّنات الكاملة على العبوة.',
            usage: 'لا يُستخدم إلا بعد استشارة المختص.',
            isNew: i == 1,
          ));
        }
      }
    }

    // Loyalty items: identical products, priced in points.
    for (final category in _categories.where((c) => c.scope == CatalogScope.loyalty)) {
      for (var i = 1; i <= 12; i++) {
        products.add(Product(
          id: '${category.id}_$i',
          categoryId: category.id,
          name: 'هدية الولاء $i',
          imageUrls: const ['', '', ''],
          price: (200 + i * 150).toDouble(),
          pricing: PricingKind.points,
          stock: 5,
          description: 'استبدلي نقاطك بهذه الهدية.',
          isNew: i <= 2,
        ));
      }
    }

    for (final category in _categories.where((c) => c.scope == CatalogScope.store)) {
      for (final filter in category.filters) {
        for (var i = 1; i <= 40; i++) {
          products.add(Product(
            id: '${category.id}_${filter.id}_$i',
            categoryId: category.id,
            filterId: filter.id,
            name: '${filter.name} $i',
            imageUrls: const ['', '', ''],
            price: 15000 + (i * 1250),
            stock: i % 7 == 0 ? 0 : 12,
            // Variants are per item: the admin fills in whichever apply,
            // so most products carry none. Every third one here has them
            // so the variant UI is actually exercised.
            clothingSizes: i % 3 == 0 ? _sampleSizes : const [],
            colors: i % 3 == 0 ? _sampleColors : const [],
            sizeGuide: i % 3 == 0 ? _sampleSizeGuide : const [],
            description: 'منتج عناية عالي الجودة، مناسب للاستخدام اليومي.',
            ingredients: 'ماء، زيوت طبيعية، فيتامين E، مستخلصات نباتية.',
            benefits: 'ترطيب عميق، تغذية، حماية من العوامل الخارجية.',
            usage: 'يوضع على المنطقة المراد العناية بها ويترك بضع دقائق ثم يشطف.',
            isNew: i <= 2,
          ));
        }
      }
    }
    return products;
  }

  @override
  Future<List<PromoBanner>> getPromoBanners({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.read<CachedBanners>(
        CatalogCache.bannersKey,
        CatalogCache.structureTtl,
      );
      if (cached != null) return cached;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    const banners = [
      PromoBanner(id: 'b1'),
      PromoBanner(id: 'b2'),
      PromoBanner(id: 'b3'),
    ];
    _cache.write(CatalogCache.bannersKey, banners);
    return banners;
  }

  @override
  Future<List<Category>> getCategories({
    CatalogScope scope = CatalogScope.store,
    bool forceRefresh = false,
  }) async {
    final key = CatalogCache.categoriesKey(scope);

    if (!forceRefresh) {
      final cached = _cache.read<CachedCategories>(key, CatalogCache.structureTtl);
      if (cached != null) return cached;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    final scoped = _categories.where((c) => c.scope == scope).toList();
    _cache.write(key, scoped);
    return scoped;
  }

  @override
  Future<Category> getCategory(String categoryId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.read<Category>(
        CatalogCache.categoryKey(categoryId),
        CatalogCache.structureTtl,
      );
      if (cached != null) return cached;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final category = _categories.firstWhere((c) => c.id == categoryId);
    _cache.write(CatalogCache.categoryKey(categoryId), category);
    return category;
  }

  @override
  Future<Product> getProduct(String productId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.read<Product>(
        CatalogCache.productKey(productId),
        CatalogCache.productsTtl,
      );
      if (cached != null) return cached;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final product = _allProducts.firstWhere((p) => p.id == productId);
    _cache.write(CatalogCache.productKey(productId), product);
    return product;
  }

  @override
  Future<ProductPageResult> getProducts({
    required String categoryId,
    String? filterId,
    String? cursor,
    bool forceRefresh = false,
  }) async {
    final key = CatalogCache.productsKey(
      categoryId: categoryId,
      filterId: filterId,
      cursor: cursor,
    );

    if (!forceRefresh) {
      final cached = _cache.read<ProductPageResult>(key, CatalogCache.productsTtl);
      if (cached != null) return cached;
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final matching = _allProducts
        .where((p) => p.categoryId == categoryId)
        .where((p) => filterId == null || p.filterId == filterId)
        .toList();

    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + pageSize).clamp(0, matching.length);
    final page = matching.sublist(start, end);

    final result = ProductPageResult(
      products: page,
      nextCursor: end < matching.length ? '$end' : null,
    );

    _cache.write(key, result);
    return result;
  }
}