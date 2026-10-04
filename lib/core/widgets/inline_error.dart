import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Small error line under a form field. Was duplicated identically in
/// signup_page.dart and dynamic_form_field_widget.dart — one shared
/// widget instead of two copies that would otherwise drift apart.
class InlineError extends StatelessWidget {
  final String message;

  const InlineError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingXs, right: AppConstants.spacingSm),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(message, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
      ),
    );
  }
}