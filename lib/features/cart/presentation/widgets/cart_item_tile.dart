import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';
import '../../../../../core/widgets/step_button.dart';
import '../../domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      gradient: AppColors.fireGradient,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO(logic-phase): CachedNetworkImage with the thumbnail variant.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: Container(
              width: AppConstants.cartThumbSize,
              height: AppConstants.cartThumbSize,
              color: AppColors.surfaceDark,
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.textDisabled,
                size: AppConstants.iconMd,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  '${item.lineTotal.toStringAsFixed(0)} ${AppStrings.currencySy}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StepButton(
                      icon: Icons.delete_outline,
                      onTap: onRemove,
                      color: AppColors.surfaceDark,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StepButton(
                          icon: Icons.remove,
                          onTap: onDecrease,
                          color: AppColors.surfaceDark,
                        ),
                        SizedBox(
                          width: AppConstants.spacingLg,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        StepButton(
                          icon: Icons.add,
                          onTap: onIncrease,
                          color: AppColors.surfaceDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}