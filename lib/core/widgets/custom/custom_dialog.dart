import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';
import 'custom_button.dart';

/// Usage: await showCustomDialog(context, title: '...', message: '...');
Future<void> showCustomDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? confirmText,
  String? cancelText,
  VoidCallback? onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
      title: title != null ? Text(title) : null,
      content: message != null ? Text(message) : null,
      actions: [
        if (cancelText != null)
          TextButton(onPressed: () => Navigator.pop(context), child: Text(cancelText)),
        CustomButton(
          label: confirmText ?? 'OK',
          height: 40,
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
        ),
      ],
    ),
  );
}
