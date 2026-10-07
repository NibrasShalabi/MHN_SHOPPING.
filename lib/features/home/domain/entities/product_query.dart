import 'package:equatable/equatable.dart';

import 'product.dart';

/// Which products a list shows: one category, or everything priced a
/// certain way (the loyalty store spans every points-priced category).
class ProductQuery extends Equatable {
  final String? categoryId;
  final PricingKind? pricing;

  const ProductQuery.category(String this.categoryId) : pricing = null;

  const ProductQuery.pricing(PricingKind this.pricing) : categoryId = null;

  String get cacheKey => categoryId != null ? 'c:$categoryId' : 'p:${pricing!.name}';

  bool matches(Product p) => categoryId != null ? p.categoryId == categoryId : p.pricing == pricing;

  @override
  List<Object?> get props => [categoryId, pricing];
}
