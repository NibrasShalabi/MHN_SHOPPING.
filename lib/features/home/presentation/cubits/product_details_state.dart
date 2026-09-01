import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variants.dart';

enum ProductDetailsStatus { initial, loading, success, failure }

class ProductDetailsState extends Equatable {
  final ProductDetailsStatus status;
  final Product? product;

  /// Quantity the user picked before adding to the cart.
  final int quantity;

  /// Chosen variants. Null while nothing is picked yet — the add button
  /// stays blocked until every variant the product offers is chosen, so an
  /// order can't arrive without a size.
  final ClothingSize? clothingSize;
  final int? shoeSize;
  final ProductColor? color;

  final Failure? failure;

  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.quantity = 1,
    this.clothingSize,
    this.shoeSize,
    this.color,
    this.failure,
  });

  bool get canIncrease => product != null && quantity < product!.stock;

  bool get canDecrease => quantity > 1;

  /// True when every variant the product offers has been chosen.
  bool get hasRequiredVariants {
    final p = product;
    if (p == null) return false;
    if (p.clothingSizes.isNotEmpty && clothingSize == null) return false;
    if (p.shoeSizes.isNotEmpty && shoeSize == null) return false;
    if (p.colors.isNotEmpty && color == null) return false;
    return true;
  }

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    Product? product,
    int? quantity,
    ClothingSize? clothingSize,
    int? shoeSize,
    ProductColor? color,
    Failure? failure,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      clothingSize: clothingSize ?? this.clothingSize,
      shoeSize: shoeSize ?? this.shoeSize,
      color: color ?? this.color,
      failure: failure,
    );
  }

  @override
  List<Object?> get props =>
      [status, product, quantity, clothingSize, shoeSize, color, failure];
}