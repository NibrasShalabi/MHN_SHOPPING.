import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/custom/app_logo.dart';

/// Wine gradient header with the wordmark — the one place on this screen
/// that carries the brand colour at full strength.
class AboutHero extends StatelessWidget {
  const AboutHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingXxl,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.fireGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: AppConstants.iconLg,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          const AppLogo(large: true),
          const SizedBox(height: AppConstants.spacingMd),
          const _GoldDivider(),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            AppStrings.aboutHeadline,
            style: AppTextStyles.heading2.copyWith(color: AppColors.textOnPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            AppStrings.aboutTagline,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accentLight,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Small gold rule with a diamond in the middle — used as the decorative
/// separator throughout this screen.
class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 32, height: 1, color: AppColors.gold),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm),
          child: Transform.rotate(
            angle: 0.785, // 45°
            child: Container(width: 6, height: 6, color: AppColors.gold),
          ),
        ),
        Container(width: 32, height: 1, color: AppColors.gold),
      ],
    );
  }
}