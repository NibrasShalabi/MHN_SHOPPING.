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
