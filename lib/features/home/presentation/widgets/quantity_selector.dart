import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final bool canIncrease;
  final bool canDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.canIncrease,
    required this.canDecrease,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.border, width: AppConstants.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, isEnabled: canDecrease, onTap: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
            child: Text('$quantity', style: AppTextStyles.body),
          ),
          _StepButton(icon: Icons.add, isEnabled: canIncrease, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.isEnabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: SizedBox(
        width: AppConstants.minTouchTarget,
        height: AppConstants.minTouchTarget,
        child: Icon(
          icon,
          size: AppConstants.iconSm,
          color: isEnabled ? AppColors.gold : AppColors.textDisabled,
        ),
      ),
    );
  }
}