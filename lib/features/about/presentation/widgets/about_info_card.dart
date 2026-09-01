import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';

/// Wide text block with a gold leading edge — used for الرسالة / المصدر.
class AboutInfoCard extends StatelessWidget {
  final IconData icon;
  final String body;

  const AboutInfoCard({super.key, required this.icon, required this.body});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppConstants.iconLg, color: AppColors.gold),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              body,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}