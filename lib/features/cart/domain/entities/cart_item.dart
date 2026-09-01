import 'package:equatable/equatable.dart';

/// A line in the cart.
///
/// Stores a price snapshot for display only — the authoritative total is
/// recomputed server-side at checkout from the product documents, so a
/// tampered client can't set its own price.
class CartItem extends Equatable {
  final String productId;
  final String name;
  final String? imageUrl;
  final double priceSnapshot;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.priceSnapshot,
    required this.quantity,
  });

  double get lineTotal => priceSnapshot * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      priceSnapshot: priceSnapshot,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [productId, name, imageUrl, priceSnapshot, quantity];
}