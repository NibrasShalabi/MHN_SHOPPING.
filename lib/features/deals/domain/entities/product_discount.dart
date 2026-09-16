import 'package:equatable/equatable.dart';

/// Discount applied to a specific product.
/// Unlike Promotion (which is temporary for "شرار ونار" section),
/// this is a permanent discount on individual products across any category.
class ProductDiscount extends Equatable {
  final String id;

  /// The product this discount applies to.
  final String productId;

  /// Original price (before discount).
  final double originalPrice;

  /// Discount percentage (0-100).
  final double discountPercentage;

  /// Discounted price (calculated).
  final double discountedPrice;

  const ProductDiscount({
    required this.id,
    required this.productId,
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountedPrice,
  });

  /// Factory constructor to calculate discounted price automatically.
  factory ProductDiscount.fromPercentage({
    required String id,
    required String productId,
    required double originalPrice,
    required double discountPercentage,
  }) {
    final discountedPrice = originalPrice * (1 - (discountPercentage / 100));
    return ProductDiscount(
      id: id,
      productId: productId,
      originalPrice: originalPrice,
      discountPercentage: discountPercentage,
      discountedPrice: discountedPrice,
    );
  }

  /// Savings amount in currency.
  double get savingsAmount => originalPrice - discountedPrice;

  @override
  List<Object?> get props => [
    id,
    productId,
    originalPrice,
    discountPercentage,
    discountedPrice,
  ];
}