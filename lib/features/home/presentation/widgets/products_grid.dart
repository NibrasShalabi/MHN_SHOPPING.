import 'package:flutter/material.dart';
import 'package:m_h_nshopping/features/home/presentation/widgets/product_card.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../domain/entities/product.dart';

/// Sliver grid of products.
///
/// Deliberately a sliver, not a GridView inside a scroll view: with
/// `shrinkWrap: true` Flutter has to build every child up front to measure
/// its own height, which would mean a thousand live widgets after enough
/// scrolling. As a sliver it stays lazy — only the cards near the viewport
/// are ever built, regardless of how many pages have been loaded.
class ProductsSliverGrid extends StatelessWidget {
  final List<Product> products;
  final bool Function(Product) shouldShowNewBadge;
  final ValueChanged<Product>? onProductTap;

  const ProductsSliverGrid({
    super.key,
    required this.products,
    required this.shouldShowNewBadge,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: products.length,
      gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppConstants.productCardMaxWidth,
        crossAxisSpacing: AppConstants.spacingSm,
        mainAxisSpacing: AppConstants.spacingSm,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          key: ValueKey(product.id),
          product: product,
          showNewBadge: shouldShowNewBadge(product),
          onTap: () => onProductTap?.call(product),
        );
      },
    );
  }
}