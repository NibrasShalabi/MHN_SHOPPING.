import 'package:flutter/material.dart';
import 'package:m_h_nshopping/features/home/domain/entities/product.dart';
import 'package:m_h_nshopping/features/home/presentation/widgets/product_card.dart';
import '../../../../../core/constants/app_constants.dart';

/// Column count adapts to available width (see the swiper/grid decision:
/// columns = floor(width / productCardMinWidth)) — same rule on phone,
/// tablet, or web, no device-type branching.
class ResponsiveProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product>? onProductTap;

  const ResponsiveProductGrid({super.key, required this.products, this.onProductTap});

  int _columns(double width) {
    final columns = (width / AppConstants.productCardMinWidth).floor();
    return columns.clamp(1, 8);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns(constraints.maxWidth),
            crossAxisSpacing: AppConstants.spacingSm,
            mainAxisSpacing: AppConstants.spacingSm,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product, onTap: () => onProductTap?.call(product), showNewBadge: true ,);
          },
        );
      },
    );
  }
}