import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:m_h_nshopping/features/deals/data/repositories/promotion_repository.dart';
import 'package:m_h_nshopping/features/deals/domain/entities/promotion.dart';
import 'package:m_h_nshopping/features/home/data/repository/catalog_repository.dart';
import 'package:m_h_nshopping/features/home/domain/entities/category.dart';
import 'package:m_h_nshopping/features/home/domain/entities/product.dart';
import 'package:m_h_nshopping/features/home/domain/entities/product_page_result.dart';
import 'package:m_h_nshopping/features/home/domain/entities/product_variants.dart';
import 'package:m_h_nshopping/features/home/domain/entities/promo_banner.dart';
import 'package:m_h_nshopping/features/home/presentation/cubits/product_details_cubit.dart';
import 'package:m_h_nshopping/features/home/presentation/cubits/product_details_state.dart';
import 'package:m_h_nshopping/features/suppliers/domain/entities/supplier.dart';

// ---- Fakes -----------------------------------------------------
class _FakeCatalogRepository implements CatalogRepository {
  final Product? _product;
  final bool _shouldThrow;

  _FakeCatalogRepository({Product? product, bool shouldThrow = false})
      : _product = product,
        _shouldThrow = shouldThrow;

  @override
  Future<Product> getProduct(String productId, {bool forceRefresh = false}) async {
    if (_shouldThrow) throw Exception('not found');
    return _product!;
  }

  @override Future<List<PromoBanner>> getPromoBanners({bool forceRefresh = false}) async => [];
  @override Future<List<Supplier>> getSuppliers({bool forceRefresh = false}) async => [];
  @override Future<Supplier> getSupplier(String id, {bool forceRefresh = false}) async => throw UnimplementedError();
  @override Future<List<Category>> getCategories({CatalogScope scope = CatalogScope.store, String? supplierId, bool forceRefresh = false}) async => [];
  @override Future<Category> getCategory(String id, {bool forceRefresh = false}) async => throw UnimplementedError();
  @override Future<ProductPageResult> getProducts({required String categoryId, String? filterId, String? cursor, bool forceRefresh = false}) async => throw UnimplementedError();
}

class _FakePromotionRepository implements PromotionRepository {
  final double _discountPct;

  _FakePromotionRepository({double discountPct = 0}) : _discountPct = discountPct;

  @override Future<double> getActiveDiscountPercentage(String productId) async => _discountPct;
  @override Future<List<Promotion>> getActivePromotions() async => [];
  @override Future<Promotion> getPromotion(String id) async => throw UnimplementedError();
  @override Future<List<Promotion>> getPromotionsForProduct(String productId) async => [];
  @override Future<bool> hasActivePromotion(String productId) async => _discountPct > 0;
}

// ---- Helpers ---------------------------------------------------
const _simpleProduct = Product(
  id: 'p1', categoryId: 'hair', name: 'سيروم 1', price: 100.0, stock: 10,
);

final _productWithDiscount = Product(
  id: 'p2', categoryId: 'hair', name: 'سيروم 2', price: 100.0, stock: 10,
  discountPercentage: 25,
  discountEndTime: DateTime.now().add(const Duration(days: 3)),
);

final _productWithExpiredDiscount = Product(
  id: 'p3', categoryId: 'hair', name: 'سيروم 3', price: 100.0, stock: 10,
  discountPercentage: 25,
  discountEndTime: DateTime.now().subtract(const Duration(hours: 1)),
);

final _productWithSizes = Product(
  id: 'p4', categoryId: 'hair', name: 'سيروم 4', price: 100.0, stock: 10,
  clothingSizes: const [ClothingSize.s, ClothingSize.m, ClothingSize.l],
);

ProductDetailsCubit _cubit(Product product, {double promotionDiscount = 0}) =>
    ProductDetailsCubit(
      _FakeCatalogRepository(product: product),
      _FakePromotionRepository(discountPct: promotionDiscount),
      productId: product.id,
    );

void main() {
  group('load()', () {
    // 3.1
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.1 — تحميل ناجح: product يظهر',
      build: () => _cubit(_simpleProduct),
      act: (c) => c.load(),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.status, 'status', ProductDetailsStatus.success)
            .having((s) => s.product?.id, 'product id', 'p1'),
      ],
    );

    // 3.2
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.2 — تحميل فاشل: status = failure',
      build: () => ProductDetailsCubit(
        _FakeCatalogRepository(shouldThrow: true),
        _FakePromotionRepository(),
        productId: 'p999',
      ),
      act: (c) => c.load(),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.status, 'status', ProductDetailsStatus.failure)
            .having((s) => s.failure, 'failure', isNotNull),
      ],
    );

    // 3.3
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.3 — بدون promotion: appliedPrice = product.price',
      build: () => _cubit(_simpleProduct),
      act: (c) => c.load(),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.appliedPrice, 'appliedPrice', 100.0),
      ],
    );

    // 3.4
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.4 — خصم دائم على المنتج: appliedPrice = effectivePrice',
      build: () => _cubit(_productWithDiscount),
      act: (c) => c.load(),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.appliedPrice, 'appliedPrice', 75.0),
      ],
    );

    // 3.5
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.5 — promotion نشطة 70%: appliedPrice = 30% من السعر',
      build: () => _cubit(_simpleProduct, promotionDiscount: 70),
      act: (c) => c.load(),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.appliedPrice, 'appliedPrice', closeTo(30.0, 0.001)),
      ],
    );

    // 3.6
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.6 — خصم دائم منتهي: appliedPrice = product.price',
      build: () => _cubit(_productWithExpiredDiscount),
      act: (c) => c.load(),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.appliedPrice, 'appliedPrice', 100.0),
      ],
    );

    // 3.7
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.7 — promotion 70% + خصم دائم 25%: appliedPrice = 30 (الـ promotion أعلى)',
      build: () => _cubit(_productWithDiscount, promotionDiscount: 70),
      act: (c) => c.load(),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.appliedPrice, 'appliedPrice', closeTo(30.0, 0.001)),
      ],
    );
  });

  group('quantity', () {
    // 3.8
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.8 — زيادة الكمية: quantity + 1',
      build: () => _cubit(_simpleProduct),
      seed: () => ProductDetailsState(status: ProductDetailsStatus.success, product: _simpleProduct, quantity: 2),
      act: (c) => c.increaseQuantity(),
      expect: () => [isA<ProductDetailsState>().having((s) => s.quantity, 'quantity', 3)],
    );

    // 3.9
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.9 — نقص الكمية: quantity - 1',
      build: () => _cubit(_simpleProduct),
      seed: () => ProductDetailsState(status: ProductDetailsStatus.success, product: _simpleProduct, quantity: 3),
      act: (c) => c.decreaseQuantity(),
      expect: () => [isA<ProductDetailsState>().having((s) => s.quantity, 'quantity', 2)],
    );

    // 3.10
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.10 — نقص عند 1: ما في تغيير',
      build: () => _cubit(_simpleProduct),
      seed: () => ProductDetailsState(status: ProductDetailsStatus.success, product: _simpleProduct, quantity: 1),
      act: (c) => c.decreaseQuantity(),
      expect: () => [],
    );

    // 3.11
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.11 — زيادة عند stock: ما في تغيير',
      build: () => _cubit(_simpleProduct),
      seed: () => ProductDetailsState(status: ProductDetailsStatus.success, product: _simpleProduct, quantity: 10),
      act: (c) => c.increaseQuantity(),
      expect: () => [],
    );
  });


  group('priceChanged', () {
    // ثغرة 2: المستخدم يُبلَّغ لما السعر يتغير
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.16 — priceChanged = false عند أول تحميل',
      build: () => _cubit(_simpleProduct),
      act: (c) => c.load(),
      expect: () => [
        const ProductDetailsState(status: ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.priceChanged, 'priceChanged', isFalse),
      ],
    );

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.17 — priceChanged = true لما السعر يتغير بعد reload',
      build: () => _cubit(_simpleProduct, promotionDiscount: 50),
      seed: () => ProductDetailsState(
        status: ProductDetailsStatus.success,
        product: _simpleProduct,
        appliedPrice: 100.0, // السعر القديم
      ),
      act: (c) => c.load(),
      expect: () => [
        isA<ProductDetailsState>().having((s) => s.status, 'status', ProductDetailsStatus.loading),
        isA<ProductDetailsState>()
            .having((s) => s.priceChanged, 'priceChanged', isTrue)
            .having((s) => s.appliedPrice, 'appliedPrice', closeTo(50.0, 0.001)),
      ],
    );
  });

  group('variant selection', () {
    // 3.12
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      '3.12 — اختيار size: clothingSize يتسجل',
      build: () => _cubit(_productWithSizes),
      seed: () => ProductDetailsState(status: ProductDetailsStatus.success, product: _productWithSizes),
      act: (c) => c.selectClothingSize(ClothingSize.m),
      expect: () => [isA<ProductDetailsState>().having((s) => s.clothingSize, 'clothingSize', ClothingSize.m)],
    );

    // 3.13
    test('3.13 — hasRequiredVariants = false قبل اختيار size', () {
      final state = ProductDetailsState(status: ProductDetailsStatus.success, product: _productWithSizes);
      expect(state.hasRequiredVariants, isFalse);
    });

    // 3.14
    test('3.14 — hasRequiredVariants = true بعد اختيار size', () {
      final state = ProductDetailsState(
        status: ProductDetailsStatus.success,
        product: _productWithSizes,
        clothingSize: ClothingSize.m,
      );
      expect(state.hasRequiredVariants, isTrue);
    });

    // 3.15
    test('3.15 — منتج بدون variants: hasRequiredVariants = true', () {
      const state = ProductDetailsState(status: ProductDetailsStatus.success, product: _simpleProduct);
      expect(state.hasRequiredVariants, isTrue);
    });
  });
}