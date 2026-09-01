import '../../domain/entities/cart_item.dart';

/// Read/write access to carts shared between users.
///
/// A shared cart is a snapshot, not a live view: the sender's later edits
/// must not change what the recipient was shown, and the recipient must
/// never be able to write back into someone else's cart.
abstract class SharedCartRepository {
  /// Publishes the current cart and returns the id to share.
  Future<String> shareCart(List<CartItem> items);

  /// Null when the link is unknown or has expired.
  Future<List<CartItem>?> getSharedCart(String cartId);
}

/// UI-phase implementation.
///
/// NOTE(logic-phase): shared carts need three things server side:
///   1. A TTL — links shouldn't resolve forever, and expired snapshots
///      should be swept rather than left to accumulate.
///   2. Read-only access by id for anyone holding the link, with no way to
///      list or enumerate them.
///   3. Rate limiting on creation, or the collection becomes free storage
///      for anyone with the app.
class FakeSharedCartRepository implements SharedCartRepository {
  final Map<String, List<CartItem>> _shared = {};

  @override
  Future<String> shareCart(List<CartItem> items) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    // Copied, not referenced: the snapshot must not track later edits.
    _shared[id] = List.unmodifiable(items);
    return id;
  }

  @override
  Future<List<CartItem>?> getSharedCart(String cartId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Demo fallback so an incoming link works during the UI phase even
    // though nothing was shared in this session.
    return _shared[cartId] ??
        const [
          CartItem(
            productId: 'hair_serum_1',
            name: 'سيروم 1',
            priceSnapshot: 16250,
            quantity: 2,
          ),
          CartItem(
            productId: 'skin_cream_3',
            name: 'كريمات 3',
            priceSnapshot: 18750,
            quantity: 1,
          ),
        ];
  }
}