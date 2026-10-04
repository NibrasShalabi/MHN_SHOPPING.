import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

/// Usage: await showCustomBottomSheet(context, child: ..., title: '...');
Future<void> showCustomBottomSheet(
  BuildContext context, {
  required Widget child,
  String? title,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppConstants.spacingMd),
          ],
          child,
        ],
      ),
    ),
  );
}
