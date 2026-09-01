import '../../domain/entities/cart_item.dart';

/// Contract for cart persistence.
///
/// The cart survives app closes (a hard requirement), so this is always
/// backed by local storage first. The logic phase swaps the fake for a
/// Hive-backed implementation plus a single Firestore document per user
/// (one doc, not a subcollection — one read to restore the whole cart).
abstract class CartRepository {
  Future<List<CartItem>> getItems();

  /// Writes the whole cart in one go.
  ///
  /// Per-item methods would mean a read-modify-write cycle per tap; the
  /// cart is a single document anyway (one read to restore it), so
  /// replacing it wholesale is both cheaper and simpler. The cubit
  /// debounces the calls.
  Future<void> saveItems(List<CartItem> items);
}

/// UI-phase implementation — in-memory, seeded with a couple of lines so
/// the screen has something to show before the cart flow is wired up.
class FakeCartRepository implements CartRepository {
  final List<CartItem> _items = [
    const CartItem(
      productId: 'hair_serum_1',
      name: 'سيروم 1',
      priceSnapshot: 16250,
      quantity: 2,
    ),
    const CartItem(
      productId: 'skin_cream_3',
      name: 'كريمات 3',
      priceSnapshot: 18750,
      quantity: 1,
    ),
  ];

  @override
  Future<List<CartItem>> getItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_items);
  }

  @override
  Future<void> saveItems(List<CartItem> items) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _items
      ..clear()
      ..addAll(items);
  }
}