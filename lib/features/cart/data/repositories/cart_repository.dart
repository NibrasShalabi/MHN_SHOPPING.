import '../../domain/entities/cart_item.dart';

/// Contract for cart persistence.
///
/// One Firestore document per user (not a subcollection) — one read
/// restores the whole cart.
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
