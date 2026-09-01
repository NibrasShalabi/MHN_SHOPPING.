import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';

/// Renders a product's price in the right unit.
///
/// One widget so the money/points split is decided in a single place —
/// otherwise every card, row and details screen has to remember the rule.
class PriceText extends StatelessWidget {
  final Product product;
  final TextStyle style;

  const PriceText({super.key, required this.product, required this.style});

  @override
  Widget build(BuildContext context) {
    final amount = product.price.toStringAsFixed(0);
    final isPoints = product.pricing == PricingKind.points;

    if (!isPoints) {
      return Text(
        '$amount ${AppStrings.currencySy}',
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Points carry the flame mark, same as the balance in the app bar, so
    // the two read as the same currency.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: (style.fontSize ?? AppConstants.iconSm) + 2,
          color: style.color ?? AppColors.gold,
        ),
        const SizedBox(width: AppConstants.spacingXs),
        Flexible(
          child: Text(
            '$amount ${AppStrings.pointsUnit}',
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}