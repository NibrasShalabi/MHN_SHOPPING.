import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variants.dart';

enum ProductDetailsStatus { initial, loading, success, failure }

class ProductDetailsState extends Equatable {
  final ProductDetailsStatus status;
  final Product? product;
  final int quantity;
  final ClothingSize? clothingSize;
  final int? shoeSize;
  final ProductColor? color;
  final Failure? failure;

  /// السعر الفعلي بعد تطبيق الـ promotion أو الخصم الدائم.
  /// هذا هو اللي يُحفظ بالسلة كـ priceSnapshot.
  final double? appliedPrice;
  final bool priceChanged;

  const ProductDetailsState({
    this.status = ProductDetailsStatus.initial,
    this.product,
    this.quantity = 1,
    this.clothingSize,
    this.shoeSize,
    this.color,
    this.failure,
    this.appliedPrice,
    this.priceChanged = false,
  });

  bool get canIncrease => product != null && quantity < product!.stock;
  bool get canDecrease => quantity > 1;

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
    double? appliedPrice,
    bool? priceChanged,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      clothingSize: clothingSize ?? this.clothingSize,
      shoeSize: shoeSize ?? this.shoeSize,
      color: color ?? this.color,
      failure: failure,
      appliedPrice: appliedPrice ?? this.appliedPrice,
      priceChanged: priceChanged ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [status, product, quantity, clothingSize, shoeSize, color, failure, appliedPrice, priceChanged];
}