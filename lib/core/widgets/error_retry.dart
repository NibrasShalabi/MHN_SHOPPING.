import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../error/failures.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'custom/custom_button.dart';

/// A screen that failed to load: what went wrong, in Arabic, and a way to
/// try again — never a dead end.
class ErrorRetry extends StatelessWidget {
  final Failure? failure;
  final VoidCallback onRetry;

  const ErrorRetry({super.key, required this.failure, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final offline = failure is NetworkFailure;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: AppConstants.iconXl, color: AppColors.textSecondary),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              failure?.message ?? AppStrings.somethingWentWrong,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            CustomButton(label: AppStrings.retry, icon: Icons.refresh, onPressed: onRetry, isOutlined: true),
          ],
        ),
      ),
    );
  }
}
