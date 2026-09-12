import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/step_button.dart';

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
          StepButton(
            icon: Icons.remove,
            isEnabled: canDecrease,
            onTap: onDecrease,
            color: AppColors.gold,
            radius: AppConstants.radiusMd,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
            child: Text('$quantity', style: AppTextStyles.body),
          ),
          StepButton(
            icon: Icons.add,
            isEnabled: canIncrease,
            onTap: onIncrease,
            color: AppColors.gold,
            radius: AppConstants.radiusMd,
          ),
        ],
      ),
    );
  }
}