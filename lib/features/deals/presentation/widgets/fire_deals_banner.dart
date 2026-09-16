import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class FireDealsBanner extends StatelessWidget {
  final VoidCallback onTap;

  const FireDealsBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          gradient: AppColors.fireGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.gold, width: AppConstants.borderThick),
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 56)),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.dealsTitle,
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textHeading,
                      fontFamily: 'ArefRuqaa',
                      fontWeight: FontWeight.bold,
                      fontSize: (AppTextStyles.heading2.fontSize ?? 18) + 4,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    AppStrings.dealsSubtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentLight,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.dealsButton,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingXs),
                      const Icon(
                        Icons.chevron_left,
                        size: AppConstants.iconSm,
                        color: AppColors.goldLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}