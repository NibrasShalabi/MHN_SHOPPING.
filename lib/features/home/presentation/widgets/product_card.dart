import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';
import 'price_text.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  /// False once the user has already seen this product — the admin's "new"
  /// flag stays set, but the badge stops rendering for this user.
  final bool showNewBadge;

  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.showNewBadge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.border, width: AppConstants.borderThin),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // TODO(logic-phase): swap for CachedNetworkImage from R2.
                  Container(
                    color: AppColors.surfaceDark,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.textDisabled,
                      size: AppConstants.iconLg,
                    ),
                  ),
                  if (showNewBadge)
                    Positioned(
                      top: AppConstants.spacingSm,
                      right: AppConstants.spacingSm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          AppStrings.newBadge,
                          style: AppTextStyles.caption.copyWith(color: AppColors.goldDark),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  PriceText(
                    product: product,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}