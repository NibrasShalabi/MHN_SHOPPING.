import '../../../../core/constants/app_constants.dart';
import 'package:equatable/equatable.dart';
import 'product_variants.dart';

enum PricingKind { money, points }

class Product extends Equatable {
  final String id;
  final String categoryId;
  final String? filterId;
  final String name;
  final List<String> imageUrls;
  final double price;
  final PricingKind pricing;
  final bool isOrderable;
  final int stock;
  final String? description;
  final String? ingredients;
  final String? benefits;
  final String? usage;
  final bool isNew;
  /// Whatever the admin's size set holds — S/M/L, 1-4 years, 38/39/40…
  final List<String> sizes;
  final List<ProductColor> colors;
  final List<SizeGuideRow> sizeGuide;

  // NEW: خصم دائم على المنتج
  final double? discountPercentage;
  final DateTime? discountEndTime;

  /// Supply shipping per piece (source → shop), added at checkout. 0 = free.
  final double shippingPrice;

  /// Set when a supplier sells it — ordered from them on WhatsApp, not the cart.
  final String? supplierId;

  const Product({
    required this.id,
    required this.categoryId,
    this.filterId,
    required this.name,
    this.imageUrls = const [],
    required this.price,
    this.pricing = PricingKind.money,
    this.isOrderable = true,
    this.stock = 0,
    this.description,
    this.ingredients,
    this.benefits,
    this.usage,
    this.isNew = false,
    this.sizes = const [],
    this.colors = const [],
    this.sizeGuide = const [],
    this.discountPercentage,
    this.discountEndTime,
    this.shippingPrice = 0,
    this.supplierId,
  });

  bool get isInStock => stock > 0;
  bool get isLowStock => isInStock && stock <= AppConstants.lowStockThreshold;
  bool get hasSizes => sizes.isNotEmpty;
  bool get hasColors => colors.isNotEmpty;
  bool get hasSizeGuide => sizeGuide.isNotEmpty;
  String? get thumbnailUrl => imageUrls.isEmpty ? null : imageUrls.first;

  bool get hasActiveDiscount {
    if (discountPercentage == null || discountPercentage == 0) return false;
    if (discountEndTime != null && DateTime.now().isAfter(discountEndTime!)) return false;
    return true;
  }

  double get effectivePrice {
    if (!hasActiveDiscount) return price;
    return price * (1 - (discountPercentage! / 100));
  }

  double get savingsAmount => price - effectivePrice;

  /// The same product with a time-limited discount (a fire deal).
  Product withDiscount(double percentage, DateTime endTime) => Product(
        id: id,
        categoryId: categoryId,
        filterId: filterId,
        name: name,
        imageUrls: imageUrls,
        price: price,
        pricing: pricing,
        isOrderable: isOrderable,
        stock: stock,
        description: description,
        ingredients: ingredients,
        benefits: benefits,
        usage: usage,
        isNew: isNew,
        sizes: sizes,
        colors: colors,
        sizeGuide: sizeGuide,
        discountPercentage: percentage,
        discountEndTime: endTime,
        shippingPrice: shippingPrice,
        supplierId: supplierId,
      );

  @override
  List<Object?> get props => [
    id, categoryId, filterId, name, imageUrls, price, pricing,
    isOrderable, stock, description, ingredients, benefits, usage,
    isNew, sizes, colors, sizeGuide,
    discountPercentage, discountEndTime, shippingPrice, supplierId,
  ];
}