import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:m_h_nshopping/features/cart/data/repositories/cart_repository.dart';
import 'package:m_h_nshopping/features/cart/domain/entities/cart_item.dart';
import 'package:m_h_nshopping/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:m_h_nshopping/features/cart/presentation/cubits/cart_state.dart';
import 'package:m_h_nshopping/features/home/data/repository/catalog_repository.dart';
import 'package:m_h_nshopping/features/home/domain/entities/category.dart';
import 'package:m_h_nshopping/features/home/domain/entities/product.dart';
import 'package:m_h_nshopping/features/home/domain/entities/product_page_result.dart';
import 'package:m_h_nshopping/features/home/domain/entities/promo_banner.dart';
import 'package:m_h_nshopping/features/suppliers/domain/entities/supplier.dart';

// ---- Fakes -----------------------------------------------------
class _FakeCartRepository implements CartRepository {
  List<CartItem> _items;
  final bool _shouldThrow;

  _FakeCartRepository({List<CartItem>? items, bool shouldThrow = false})
      : _items = items ?? [],
        _shouldThrow = shouldThrow;

  @override
  Future<List<CartItem>> getItems() async {
    if (_shouldThrow) throw Exception('error');
    return _items;
  }

  @override
  Future<void> saveItems(List<CartItem> items) async {
    _items = items;
  }
}

class _FakeCatalogRepository implements CatalogRepository {
  final Set<String> _unavailableIds;

  _FakeCatalogRepository({Set<String>? unavailableIds})
      : _unavailableIds = unavailableIds ?? {};

  @override
  Future<Product> getProduct(String productId, {bool forceRefresh = false}) async {
    if (_unavailableIds.contains(productId)) throw Exception('not found');
    return Product(id: productId, categoryId: 'hair', name: 'Product', price: 10, stock: 10);
  }

  @override Future<List<PromoBanner>> getPromoBanners({bool forceRefresh = false}) async => [];
  @override Future<List<Supplier>> getSuppliers({bool forceRefresh = false}) async => [];
  @override Future<Supplier> getSupplier(String id, {bool forceRefresh = false}) async => throw UnimplementedError();
  @override Future<List<Category>> getCategories({CatalogScope scope = CatalogScope.store, String? supplierId, bool forceRefresh = false}) async => [];
  @override Future<Category> getCategory(String id, {bool forceRefresh = false}) async => throw UnimplementedError();
  @override Future<ProductPageResult> getProducts({required String categoryId, String? filterId, String? cursor, bool forceRefresh = false}) async => throw UnimplementedError();
}

CartItem _item(String id, {double price = 10.0, int qty = 1}) => CartItem(
  productId: id, name: 'Product $id', priceSnapshot: price, quantity: qty,
);

CartCubit _cubit({List<CartItem>? items, Set<String>? unavailable, bool cartThrows = false}) =>
    CartCubit(
      _FakeCartRepository(items: items, shouldThrow: cartThrows),
      _FakeCatalogRepository(unavailableIds: unavailable),
    );

void main() {
  group('load()', () {
    // 1.1
    blocTest<CartCubit, CartState>(
      '1.1 — success: items تظهر',
      build: () => _cubit(items: [_item('p1')]),
      act: (c) => c.load(),
      expect: () => [
        const CartState(status: CartStatus.loading),
        CartState(status: CartStatus.success, items: [_item('p1')]),
      ],
    );

    // 1.2
    blocTest<CartCubit, CartState>(
      '1.2 — failure: status = failure',
      build: () => _cubit(cartThrows: true),
      act: (c) => c.load(),
      expect: () => [
        const CartState(status: CartStatus.loading),
        isA<CartState>()
            .having((s) => s.status, 'status', CartStatus.failure)
            .having((s) => s.failure, 'failure', isNotNull),
      ],
    );

    // جديد: unavailable items
    blocTest<CartCubit, CartState>(
      '1.15 — منتج محذوف من الـ catalog: يظهر بـ unavailableProductIds',
      build: () => _cubit(
        items: [_item('p1'), _item('deleted')],
        unavailable: {'deleted'},
      ),
      act: (c) => c.load(),
      expect: () => [
        const CartState(status: CartStatus.loading),
        isA<CartState>()
            .having((s) => s.status, 'status', CartStatus.success)
            .having((s) => s.unavailableProductIds, 'unavailable', {'deleted'})
            .having((s) => s.items.length, 'items', 2),
      ],
    );

    // جديد: كل المنتجات متوفرة
    blocTest<CartCubit, CartState>(
      '1.16 — كل المنتجات متوفرة: unavailableProductIds فارغة',
      build: () => _cubit(items: [_item('p1'), _item('p2')]),
      act: (c) => c.load(),
      expect: () => [
        const CartState(status: CartStatus.loading),
        isA<CartState>()
            .having((s) => s.unavailableProductIds, 'unavailable', isEmpty),
      ],
    );
  });

  group('addItem()', () {
    // 1.3
    blocTest<CartCubit, CartState>(
      '1.3 — منتج جديد: يُضاف للقائمة',
      build: () => _cubit(),
      seed: () => const CartState(status: CartStatus.success),
      act: (c) => c.addItem(_item('p1', price: 15.0)),
      expect: () => [
        CartState(status: CartStatus.success, items: [_item('p1', price: 15.0)]),
      ],
    );

    // 1.4
    blocTest<CartCubit, CartState>(
      '1.4 — منتج موجود: الكمية تتجمع',
      build: () => _cubit(),
      seed: () => CartState(status: CartStatus.success, items: [_item('p1', qty: 2)]),
      act: (c) => c.addItem(_item('p1', qty: 3)),
      expect: () => [
        CartState(status: CartStatus.success, items: [_item('p1', qty: 5)]),
      ],
    );

    // جديد: case 3 — تحديث السعر
    blocTest<CartCubit, CartState>(
      '1.17 — نفس المنتج بسعر جديد: priceSnapshot يتحدث لآخر سعر',
      build: () => _cubit(),
      seed: () => CartState(
        status: CartStatus.success,
        items: [_item('p1', price: 100.0, qty: 2)],
      ),
      act: (c) => c.addItem(_item('p1', price: 80.0, qty: 1)),
      expect: () => [
        isA<CartState>()
            .having((s) => s.items.first.priceSnapshot, 'price', 80.0)
            .having((s) => s.items.first.quantity, 'qty', 3),
      ],
    );
  });

  group('increaseQuantity() / decreaseQuantity()', () {
    // 1.5
    blocTest<CartCubit, CartState>(
      '1.5 — زيادة الكمية: quantity + 1',
      build: () => _cubit(),
      seed: () => CartState(status: CartStatus.success, items: [_item('p1', qty: 2)]),
      act: (c) => c.increaseQuantity('p1'),
      expect: () => [CartState(status: CartStatus.success, items: [_item('p1', qty: 3)])],
    );

    // 1.6
    blocTest<CartCubit, CartState>(
      '1.6 — نقص الكمية: quantity - 1',
      build: () => _cubit(),
      seed: () => CartState(status: CartStatus.success, items: [_item('p1', qty: 3)]),
      act: (c) => c.decreaseQuantity('p1'),
      expect: () => [CartState(status: CartStatus.success, items: [_item('p1', qty: 2)])],
    );

    // 1.7
    blocTest<CartCubit, CartState>(
      '1.7 — نقص عند 1: يُحذف',
      build: () => _cubit(),
      seed: () => CartState(status: CartStatus.success, items: [_item('p1', qty: 1)]),
      act: (c) => c.decreaseQuantity('p1'),
      expect: () => [const CartState(status: CartStatus.success, items: [])],
    );

    // 1.8
    blocTest<CartCubit, CartState>(
      '1.8 — منتج غير موجود: ما في تغيير',
      build: () => _cubit(),
      seed: () => CartState(status: CartStatus.success, items: [_item('p1', qty: 2)]),
      act: (c) => c.increaseQuantity('p999'),
      expect: () => [],
    );
  });

  // 1.9
  group('removeItem()', () {
    blocTest<CartCubit, CartState>(
      '1.9 — حذف منتج: يختفي',
      build: () => _cubit(),
      seed: () => CartState(status: CartStatus.success, items: [_item('p1'), _item('p2')]),
      act: (c) => c.removeItem('p1'),
      expect: () => [CartState(status: CartStatus.success, items: [_item('p2')])],
    );
  });

  // 1.10
  group('clear()', () {
    blocTest<CartCubit, CartState>(
      '1.10 — مسح السلة: فارغة',
      build: () => _cubit(),
      seed: () => CartState(status: CartStatus.success, items: [_item('p1'), _item('p2')]),
      act: (c) => c.clear(),
      expect: () => [const CartState(status: CartStatus.success, items: [])],
    );
  });

  group('CartState getters', () {
    test('1.11 — totalCount صح', () {
      final s = CartState(status: CartStatus.success, items: [_item('p1', qty: 2), _item('p2', qty: 3)]);
      expect(s.totalCount, 5);
    });

    test('1.12 — subtotal صح', () {
      final s = CartState(status: CartStatus.success, items: [_item('p1', price: 10, qty: 2), _item('p2', price: 5, qty: 4)]);
      expect(s.subtotal, 40.0);
    });

    test('1.13 — isEmpty = true', () => expect(const CartState(status: CartStatus.success).isEmpty, isTrue));
    test('1.14 — isEmpty = false', () {
      expect(CartState(status: CartStatus.success, items: [_item('p1')]).isEmpty, isFalse);
    });

    // جديد: case 5 و 6
    test('1.18 — isReadyForCheckout = true لما ما في unavailable', () {
      final s = CartState(status: CartStatus.success, items: [_item('p1')]);
      expect(s.isReadyForCheckout, isTrue);
    });

    test('1.19 — isReadyForCheckout = false لما في unavailable', () {
      final s = CartState(
        status: CartStatus.success,
        items: [_item('p1')],
        unavailableProductIds: {'p1'},
      );
      expect(s.isReadyForCheckout, isFalse);
    });

    test('1.20 — isReadyForCheckout = false لما السلة فارغة', () {
      expect(const CartState(status: CartStatus.success).isReadyForCheckout, isFalse);
    });
  });
}