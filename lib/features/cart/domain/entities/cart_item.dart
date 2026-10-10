import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/product.dart';
import '../../../home/domain/entities/product_variants.dart';

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

  /// Supply shipping per piece, from the product. 0 = free.
  final double shippingPerUnit;

  /// What the customer picked — the same product in two sizes is two lines.
  final String? size;
  final ProductColor? color;

  const CartItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.priceSnapshot,
    required this.quantity,
    this.pricing = PricingKind.money,
    this.shippingPerUnit = 0,
    this.size,
    this.color,
  });

  /// Identifies the line: product plus the chosen size and colour.
  String get lineKey => '$productId|${size ?? ''}|${color?.name ?? ''}';

  bool get hasVariant => size != null || color != null;

  bool get isPoints => pricing == PricingKind.points;

  double get lineTotal => priceSnapshot * quantity;
  double get lineShipping => shippingPerUnit * quantity;

  /// Re-applies what the product says now — used when the cart loads.
  CartItem syncedWith(Product product) => CartItem(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        priceSnapshot: priceSnapshot,
        quantity: quantity,
        pricing: product.pricing,
        shippingPerUnit: product.shippingPrice,
        size: size,
        color: color,
      );

  CartItem copyWith({int? quantity, double? priceSnapshot}) => CartItem(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        priceSnapshot: priceSnapshot ?? this.priceSnapshot,
        quantity: quantity ?? this.quantity,
        pricing: pricing,
        shippingPerUnit: shippingPerUnit,
        size: size,
        color: color,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'imageUrl': imageUrl,
        'priceSnapshot': priceSnapshot,
        'quantity': quantity,
        'pricing': pricing.name,
        'shippingPerUnit': shippingPerUnit,
        'size': ?size,
        if (color case final c?) 'color': {'name': c.name, 'value': c.value},
      };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        productId: m['productId'] as String? ?? '',
        name: m['name'] as String? ?? '',
        imageUrl: m['imageUrl'] as String?,
        priceSnapshot: (m['priceSnapshot'] as num? ?? 0).toDouble(),
        quantity: (m['quantity'] as num? ?? 1).toInt(),
        pricing: m['pricing'] == PricingKind.points.name ? PricingKind.points : PricingKind.money,
        shippingPerUnit: (m['shippingPerUnit'] as num? ?? 0).toDouble(),
        size: m['size'] as String?,
        color: switch (m['color']) {
          {'name': final String name, 'value': final int value} => ProductColor(name: name, value: value),
          _ => null,
        },
      );

  @override
  List<Object?> get props => [productId, name, imageUrl, priceSnapshot, quantity, pricing, shippingPerUnit, size, color];
}
