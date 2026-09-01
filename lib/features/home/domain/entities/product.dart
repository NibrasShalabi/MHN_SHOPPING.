import 'package:equatable/equatable.dart';

import 'product_variants.dart';

/// What a product's [Product.price] is denominated in.
///
/// The loyalty store sells the same products through the same cards and
/// details screen — only the unit changes. Carrying that as a field beats
/// a parallel "LoyaltyProduct" type that would duplicate every widget.
enum PricingKind { money, points }

class Product extends Equatable {
  final String id;
  final String categoryId;
  final String? filterId;
  final String name;

  /// Ordered — the first one is the card thumbnail.
  final List<String> imageUrls;

  final double price;

  /// Whether [price] is currency or loyalty points.
  final PricingKind pricing;

  /// Whether the item can go in the cart.
  ///
  /// Supervised products (supplements, weight-loss items) still show a
  /// price — the user should know what it costs — but are prescribed by
  /// the specialist, so the buy controls are absent rather than disabled.
  final bool isOrderable;

  final int stock;
  final String? description;
  final String? ingredients;
  final String? benefits;
  final String? usage;
  final bool isNew;

  /// Variants. All optional: the admin fills in whichever apply to the
  /// item, so a shampoo has none and a jacket has sizes and colours.
  final List<ClothingSize> clothingSizes;
  final List<int> shoeSizes;
  final List<ProductColor> colors;

  /// Per-product size chart, shown from the icon next to the size row.
  /// Empty means the product has no chart to show.
  final List<SizeGuideRow> sizeGuide;

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
  });

  bool get isInStock => stock > 0;

  bool get hasSizes => clothingSizes.isNotEmpty || shoeSizes.isNotEmpty;

  bool get hasColors => colors.isNotEmpty;

  bool get hasSizeGuide => sizeGuide.isNotEmpty;

  String? get thumbnailUrl => imageUrls.isEmpty ? null : imageUrls.first;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    filterId,
    name,
    imageUrls,
    price,
    pricing,
    isOrderable,
    stock,
    description,
    ingredients,
    benefits,
    usage,
    isNew,
    clothingSizes,
    shoeSizes,
    colors,
    sizeGuide,
  ];
}