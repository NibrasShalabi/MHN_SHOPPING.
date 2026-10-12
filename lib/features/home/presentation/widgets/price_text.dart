import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';

/// Renders a product's price in the right unit.
class PriceText extends StatelessWidget {
  final Product product;
  final TextStyle style;

  /// Colours of the discounted price and the struck-out original; on the
  /// fire backdrop red would vanish, so cards pass their own.
  final Color discountColor;
  final Color strikeColor;

  const PriceText({
    super.key,
    required this.product,
    required this.style,
    this.discountColor = AppColors.error,
    this.strikeColor = AppColors.textDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final isPoints = product.pricing == PricingKind.points;

    if (!isPoints) {
      final price = product.hasActiveDiscount
          ? product.effectivePrice
          : product.price;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.hasActiveDiscount)
            Text(
              '\$ ${product.price.toStringAsFixed(2)}',
              style: style.copyWith(
                fontSize: (style.fontSize ?? 12) - 2,
                color: strikeColor,
                decoration: TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            '\$ ${price.toStringAsFixed(2)}',
            style: style.copyWith(
              color: product.hasActiveDiscount ? discountColor : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: (style.fontSize ?? AppConstants.iconSm) + 2,
          color: AppColors.iconPrimary,
        ),
        const SizedBox(width: AppConstants.spacingXs),
        Flexible(
          child: Text(
            '${product.price.toStringAsFixed(0)} ${AppStrings.pointsUnit}',
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}