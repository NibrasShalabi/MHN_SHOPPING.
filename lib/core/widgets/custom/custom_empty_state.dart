import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';
import 'custom_button.dart';

class CustomEmptyState extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CustomEmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.inbox_outlined, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppConstants.spacingMd),
            if (title != null)
              Text(title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            if (message != null) ...[
              const SizedBox(height: AppConstants.spacingXs),
              Text(message!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              CustomButton(label: actionLabel!, onPressed: onAction, height: 42),
            ],
          ],
        ),
      ),
    );
  }
}
