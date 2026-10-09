import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Entry to the suppliers section, under the fire-deals banner.
///
/// Deliberately calmer than the deals banner (dark surface, thin gold rim,
/// storefront art) so the two read as different things side by side.
class SuppliersEntryBanner extends StatelessWidget {
  static const String _art = 'assets/images/suppliers.jpg';

  final VoidCallback onTap;

  const SuppliersEntryBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.radiusLg);
    return Material(
      color: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppColors.goldDark, width: AppConstants.borderThin),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
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
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppStrings.browseSuppliers, style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
                          const SizedBox(width: AppConstants.spacingXs),
                          const Icon(Icons.chevron_left, size: AppConstants.iconSm, color: AppColors.gold),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                child: Image.asset(_art, width: AppConstants.iconXxl, height: AppConstants.iconXxl, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
