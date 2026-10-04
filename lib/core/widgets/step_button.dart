import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Small tappable icon button for a +/- stepper. Was duplicated (with
/// slightly different capabilities) in cart_item_tile.dart and
/// quantity_selector.dart — this covers both, but [color] stays required:
/// the two call sites need different colors for real reasons (one sits on
/// a fire-gradient card and needs a dark icon for contrast, the other
/// sits on a plain surface and uses gold), so a shared default would
/// silently be wrong for one of them.
class StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool isEnabled;
  final double radius;

  const StepButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
    this.isEnabled = true,
    this.radius = AppConstants.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: AppConstants.minTouchTarget,
        height: AppConstants.minTouchTarget,
        child: Icon(
          icon,
          size: AppConstants.iconSm,
          color: isEnabled ? color : AppColors.textDisabled,
        ),
      ),
    );
  }
}