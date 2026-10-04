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
  final List<ClothingSize> clothingSizes;
  final List<int> shoeSizes;
  final List<ProductColor> colors;
  final List<SizeGuideRow> sizeGuide;

  // NEW: خصم دائم على المنتج
  final double? discountPercentage;
  final DateTime? discountEndTime;

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
    this.clothingSizes = const [],
    this.shoeSizes = const [],
    this.colors = const [],
    this.sizeGuide = const [],
    this.discountPercentage,
    this.discountEndTime,
  });

  bool get isInStock => stock > 0;
  bool get hasSizes => clothingSizes.isNotEmpty || shoeSizes.isNotEmpty;
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

  @override
  List<Object?> get props => [
    id, categoryId, filterId, name, imageUrls, price, pricing,
    isOrderable, stock, description, ingredients, benefits, usage,
    isNew, clothingSizes, shoeSizes, colors, sizeGuide,
    discountPercentage, discountEndTime,
  ];
}