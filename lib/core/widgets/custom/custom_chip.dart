import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  const CustomChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingXs,
        ),
        decoration: BoxDecoration(
          color: selected ? base : base.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : base, fontSize: 13),
        ),
      ),
    );
  }
}
