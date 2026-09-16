import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:m_h_nshopping/features/deals/data/repositories/promotion_repository.dart';
import 'package:m_h_nshopping/features/deals/domain/entities/promotion.dart';
import 'package:m_h_nshopping/features/home/data/repository/catalog_repository.dart';
import 'package:m_h_nshopping/features/home/domain/entities/category.dart';
import 'package:m_h_nshopping/features/home/domain/entities/product.dart';
import 'package:m_h_nshopping/features/home/domain/entities/product_page_result.dart';
import 'package:m_h_nshopping/features/home/domain/entities/promo_banner.dart';
import 'package:m_h_nshopping/features/home/presentation/cubits/home_cubit.dart';
import 'package:m_h_nshopping/features/home/presentation/cubits/home_state.dart';
import 'package:m_h_nshopping/features/suppliers/domain/entities/supplier.dart';

class _FakeCatalogRepository implements CatalogRepository {
  final bool _shouldThrow;
  _FakeCatalogRepository({bool shouldThrow = false}) : _shouldThrow = shouldThrow;

  static const _banners = [PromoBanner(id: 'b1'), PromoBanner(id: 'b2')];
  static final _categories = [
    const Category(id: 'hair', name: 'شعر', filters: []),
    const Category(id: 'skin', name: 'بشرة', filters: []),
  ];

  @override Future<List<PromoBanner>> getPromoBanners({bool forceRefresh = false}) async {
    if (_shouldThrow) throw Exception('error');
    return _banners;
  }
  @override Future<List<Category>> getCategories({CatalogScope scope = CatalogScope.store, String? supplierId, bool forceRefresh = false}) async {
    if (_shouldThrow) throw Exception('error');
    return _categories;
  }
  @override Future<Category> getCategory(String id, {bool forceRefresh = false}) async => throw UnimplementedError();
  @override Future<Product> getProduct(String id, {bool forceRefresh = false}) async => throw UnimplementedError();
  @override Future<ProductPageResult> getProducts({required String categoryId, String? filterId, String? cursor, bool forceRefresh = false}) async => throw UnimplementedError();
  @override Future<List<Supplier>> getSuppliers({bool forceRefresh = false}) async => [];
  @override Future<Supplier> getSupplier(String id, {bool forceRefresh = false}) async => throw UnimplementedError();
}

class _FakePromotionRepository implements PromotionRepository {
  final List<Promotion> _promotions;
  _FakePromotionRepository({List<Promotion>? promotions}) : _promotions = promotions ?? [];

  @override Future<List<Promotion>> getActivePromotions() async => _promotions;
  @override Future<Promotion> getPromotion(String id) async => throw UnimplementedError();
  @override Future<List<Promotion>> getPromotionsForProduct(String id) async => _promotions.where((p) => p.productId == id).toList();
  @override Future<bool> hasActivePromotion(String id) async => _promotions.any((p) => p.productId == id);
  @override Future<double> getActiveDiscountPercentage(String id) async => 0;
}

Promotion _promo(String productId) => Promotion(
  id: 'promo1', productId: productId, discountPercentage: 50,
  startTime: DateTime.now(), endTime: DateTime.now().add(const Duration(hours: 24)),
);

void main() {
  // 2.1
  blocTest<HomeCubit, HomeState>(
    '2.1 — ناجح: banners + categories + promotions',
    build: () => HomeCubit(_FakeCatalogRepository(), _FakePromotionRepository()),
    act: (c) => c.load(),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      isA<HomeState>()
          .having((s) => s.status, 'status', HomeStatus.success)
          .having((s) => s.banners.length, 'banners', 2)
          .having((s) => s.categories.length, 'categories', 2),
    ],
  );

  // 2.2
  blocTest<HomeCubit, HomeState>(
    '2.2 — فاشل: status = failure',
    build: () => HomeCubit(_FakeCatalogRepository(shouldThrow: true), _FakePromotionRepository()),
    act: (c) => c.load(),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.failure),
    ],
  );

  // 2.3
  blocTest<HomeCubit, HomeState>(
    '2.3 — reload: status يرجع loading ثم success',
    build: () => HomeCubit(_FakeCatalogRepository(), _FakePromotionRepository()),
    act: (c) async { await c.load(); await c.load(); },
    skip: 2,
    expect: () => [
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
      isA<HomeState>().having((s) => s.status, 'status', HomeStatus.success),
    ],
  );

  // 2.4
  blocTest<HomeCubit, HomeState>(
    '2.4 — ما في promotions: dealProducts = []',
    build: () => HomeCubit(_FakeCatalogRepository(), _FakePromotionRepository()),
    act: (c) => c.load(),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      isA<HomeState>().having((s) => s.promotions, 'promotions', isEmpty),
    ],
  );

  // 2.5
  blocTest<HomeCubit, HomeState>(
    '2.5 — في promotions: promotions تحتوي البيانات الصح',
    build: () => HomeCubit(
      _FakeCatalogRepository(),
      _FakePromotionRepository(promotions: [_promo('p1')]),
    ),
    act: (c) => c.load(),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      isA<HomeState>().having((s) => s.promotions.length, 'promotions', 1),
    ],
  );
}