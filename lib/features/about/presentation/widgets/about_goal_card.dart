import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';

class AboutGoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const AboutGoalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              gradient: AppColors.emberGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(icon, size: AppConstants.iconMd, color: AppColors.goldLight),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            body,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}