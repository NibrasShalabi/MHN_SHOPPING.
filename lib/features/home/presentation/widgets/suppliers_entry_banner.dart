import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Entry point to the suppliers section from the home screen.
///
/// Same shape as [FitnessEntryBanner] — one banner style for "a section
/// that lives outside the bottom nav", so a third one later is a data
/// change, not a new visual language.
class SuppliersEntryBanner extends StatelessWidget {
  final VoidCallback onTap;

  const SuppliersEntryBanner({super.key, required this.onTap});

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
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSm),
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
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.suppliersBannerTitle,
                    style: AppTextStyles.heading2.copyWith(color: AppColors.textHeading),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    AppStrings.suppliersBannerBody,
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
                        AppStrings.browseSuppliers,
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