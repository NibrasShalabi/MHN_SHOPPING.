import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Entry point to the fitness section from the home screen.
///
/// A banner rather than a bottom-nav tab or a swipe view: the section is
/// female-only, and a tab that appears for some users and not others reads
/// as something broken. A banner that's simply present or absent doesn't
/// raise that question.
///
/// Visibility is decided by the caller — this widget makes no gender
/// decision of its own, so there's one place to get that check right.
class FitnessEntryBanner extends StatelessWidget {
  final VoidCallback onTap;

  const FitnessEntryBanner({super.key, required this.onTap});

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
          border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
        ),
        child: Row(
          children: [
            const _Emblem(),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.fitnessBannerTitle,
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textHeading,
                      fontFamily: 'ArefRuqaa',
                      fontWeight: FontWeight.bold,
                      fontSize: (AppTextStyles.heading2.fontSize ?? 18) + 4,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    AppStrings.fitnessBannerBody,
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
                        AppStrings.discoverSection,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary),
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

/// The gold yoga-and-nutrition emblem on a dark medallion with a soft glow.
class _Emblem extends StatelessWidget {
  static const double size = 76;

  const _Emblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppConstants.spacingXs),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [AppColors.emberDeep, AppColors.surfaceDark]),
        border: Border.all(color: AppColors.goldLight, width: AppConstants.borderThin),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withValues(alpha: 0.45), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      child: Image.asset('assets/images/fitness_emblem.png', fit: BoxFit.contain),
    );
  }
}
