import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/product.dart';

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

  /// Loyalty-store items are priced in points and never mix into the money total.
  final PricingKind pricing;

  const CartItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.priceSnapshot,
    required this.quantity,
    this.pricing = PricingKind.money,
  });

  bool get isPoints => pricing == PricingKind.points;

  double get lineTotal => priceSnapshot * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        priceSnapshot: priceSnapshot,
        quantity: quantity ?? this.quantity,
        pricing: pricing,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'imageUrl': imageUrl,
        'priceSnapshot': priceSnapshot,
        'quantity': quantity,
        'pricing': pricing.name,
      };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        productId: m['productId'] as String? ?? '',
        name: m['name'] as String? ?? '',
        imageUrl: m['imageUrl'] as String?,
        priceSnapshot: (m['priceSnapshot'] as num? ?? 0).toDouble(),
        quantity: (m['quantity'] as num? ?? 1).toInt(),
        pricing: m['pricing'] == PricingKind.points.name ? PricingKind.points : PricingKind.money,
      );

  @override
  List<Object?> get props => [productId, name, imageUrl, priceSnapshot, quantity, pricing];
}
