import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_page_result.dart';
import '../../domain/entities/product_variants.dart';
import '../../domain/entities/promo_banner.dart';
import 'catalog_cache.dart';
import 'catalog_repository.dart';

class FirebaseCatalogRepository implements CatalogRepository {
  static const int _pageSize = 24;

  final FirebaseFirestore _db;
  final CatalogCache _cache;

  FirebaseCatalogRepository(this._db, this._cache);

  @override
  Future<List<PromoBanner>> getPromoBanners({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.read<CachedBanners>(CatalogCache.bannersKey, CatalogCache.structureTtl);
      if (cached != null) return cached;
    }
    try {
      // بدون orderBy — نرتب client-side لتجنب composite index
      final snap = await _db.collection('banners')
          .where('isActive', isEqualTo: true)
          .get();
      final banners = snap.docs.map(_bannerFromDoc).toList();
      _cache.write(CatalogCache.bannersKey, banners);
      return banners;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<List<Supplier>> getSuppliers({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.read<CachedSuppliers>(CatalogCache.suppliersKey, CatalogCache.structureTtl);
      if (cached != null) return cached;
    }
    try {
      final snap = await _db.collection('suppliers').get();
      final suppliers = snap.docs.map(_supplierFromDoc).toList();
      _cache.write(CatalogCache.suppliersKey, suppliers);
      return suppliers;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<Supplier> getSupplier(String supplierId, {bool forceRefresh = false}) async {
    try {
      final doc = await _db.collection('suppliers').doc(supplierId).get();
      if (!doc.exists) throw const NotFoundException();
      return _supplierFromDoc(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// قسم الرياضة واللياقة (fitness) لا يُعرض للذكور — يُفلتر هنا في الـ data layer
  @override
  Future<List<Category>> getCategories({
    CatalogScope scope = CatalogScope.store,
    String? supplierId,
    bool forceRefresh = false,
  }) async {
    final key = CatalogCache.categoriesKey(scope, supplierId: supplierId);
    if (!forceRefresh) {
      final cached = _cache.read<CachedCategories>(key, CatalogCache.structureTtl);
      if (cached != null) return cached;
    }
    try {
      // بدون orderBy — single field query ما تحتاج composite index
      var query = _db.collection('categories').where('scope', isEqualTo: scope.name);
      if (supplierId != null) query = query.where('supplierId', isEqualTo: supplierId);
      final snap = await query.get();
      final categories = snap.docs.map(_categoryFromDoc).toList();
      _cache.write(key, categories);
      return categories;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<Category> getCategory(String categoryId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.read<Category>(CatalogCache.categoryKey(categoryId), CatalogCache.structureTtl);
      if (cached != null) return cached;
    }
    try {
      final doc = await _db.collection('categories').doc(categoryId).get();
      if (!doc.exists) throw const NotFoundException();
      final category = _categoryFromDoc(doc);
      _cache.write(CatalogCache.categoryKey(categoryId), category);
      return category;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<Product> getProduct(String productId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.read<Product>(CatalogCache.productKey(productId), CatalogCache.productsTtl);
      if (cached != null) return cached;
    }
    try {
      final doc = await _db.collection('products').doc(productId).get();
      if (!doc.exists) throw const NotFoundException();
      final product = _productFromDoc(doc);
      _cache.write(CatalogCache.productKey(productId), product);
      return product;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<ProductPageResult> getProducts({
    required String categoryId,
    String? filterId,
    String? cursor,
    bool forceRefresh = false,
  }) async {
    final key = CatalogCache.productsKey(categoryId: categoryId, filterId: filterId, cursor: cursor);
    if (!forceRefresh) {
      final cached = _cache.read<ProductPageResult>(key, CatalogCache.productsTtl);
      if (cached != null) return cached;
    }
    try {
      var query = _db.collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (filterId != null) query = query.where('filterId', isEqualTo: filterId);

      if (cursor != null) {
        final cursorDoc = await _db.collection('products').doc(cursor).get();
        query = query.startAfterDocument(cursorDoc);
      }

      final snap = await query.get();
      final products = snap.docs.map(_productFromDoc).toList();
      final result = ProductPageResult(
        products: products,
        nextCursor: products.length == _pageSize ? snap.docs.last.id : null,
      );
      _cache.write(key, result);
      return result;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  // ===== Private Mappers =====

  PromoBanner _bannerFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PromoBanner(id: doc.id, imageUrl: d['imageUrl'] as String?, title: d['title'] as String?);
  }

  Supplier _supplierFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Supplier(
      id: doc.id,
      name: d['name'] as String? ?? '',
      logoUrl: d['logoUrl'] as String?,
      description: d['description'] as String? ?? '',
    );
  }

  Category _categoryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Category(
      id: doc.id,
      name: d['name'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      scope: CatalogScope.values.firstWhere(
            (s) => s.name == (d['scope'] as String? ?? 'store'),
        orElse: () => CatalogScope.store,
      ),
      supplierId: d['supplierId'] as String?,
      filters: (d['filters'] as List<dynamic>? ?? [])
          .map((f) => ProductFilter(id: f['id'] as String, name: f['name'] as String))
          .toList(),
    );
  }

  Product _productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Product(
      id: doc.id,
      categoryId: d['categoryId'] as String? ?? '',
      filterId: d['filterId'] as String?,
      name: d['name'] as String? ?? '',
      imageUrls: List<String>.from(d['imageUrls'] as List? ?? []),
      price: (d['price'] as num? ?? 0).toDouble(),
      pricing: PricingKind.values.firstWhere(
            (p) => p.name == (d['pricing'] as String? ?? 'money'),
        orElse: () => PricingKind.money,
      ),
      isOrderable: d['isOrderable'] as bool? ?? true,
      stock: d['stock'] as int? ?? 0,
      description: d['description'] as String?,
      ingredients: d['ingredients'] as String?,
      benefits: d['benefits'] as String?,
      usage: d['usage'] as String?,
      isNew: d['isNew'] as bool? ?? false,
      clothingSizes: (d['clothingSizes'] as List<dynamic>? ?? [])
          .map((s) => ClothingSize.values.firstWhere((e) => e.name == s, orElse: () => ClothingSize.m))
          .toList(),
      shoeSizes: List<int>.from(d['shoeSizes'] as List? ?? []),
      colors: (d['colors'] as List<dynamic>? ?? [])
          .map((c) => ProductColor(name: c['name'] as String, value: c['value'] as int))
          .toList(),
      sizeGuide: (d['sizeGuide'] as List<dynamic>? ?? [])
          .map((r) => SizeGuideRow(size: r['size'] as String, measurements: Map<String, String>.from(r['measurements'] as Map)))
          .toList(),
      discountPercentage: (d['discountPercentage'] as num?)?.toDouble(),
      discountEndTime: d['discountEndTime'] != null ? (d['discountEndTime'] as Timestamp).toDate() : null,
    );
  }
}