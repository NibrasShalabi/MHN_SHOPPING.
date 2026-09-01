import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';
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
      padding: const EdgeInsets.all(AppConstants.spacingSm),
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
                  style: AppTextStyles.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  '${item.lineTotal.toStringAsFixed(0)} ${AppStrings.currencySy}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Wrap(
                  spacing: AppConstants.spacingSm,
                  runSpacing: AppConstants.spacingXs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StepButton(icon: Icons.remove, onTap: onDecrease),
                    Text('${item.quantity}', style: AppTextStyles.body),
                    _StepButton(icon: Icons.add, onTap: onIncrease),
                    _StepButton(
                      icon: Icons.delete_outline,
                      onTap: onRemove,
                      color: AppColors.error,
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

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _StepButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: SizedBox(
        width: AppConstants.minTouchTarget,
        height: AppConstants.minTouchTarget,
        child: Icon(icon, size: AppConstants.iconSm, color: color ?? AppColors.gold),
      ),
    );
  }
}