import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Section heading with a short gold accent bar on the leading side.
class AboutSectionTitle extends StatelessWidget {
  final String title;

  const AboutSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: AppConstants.spacingLg,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(child: Text(title, style: AppTextStyles.heading2)),
      ],
    );
  }
}