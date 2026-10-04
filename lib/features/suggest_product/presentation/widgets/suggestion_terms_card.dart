import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';

/// Renders whatever is in AppStrings.suggestionTerms — add or remove a
/// line there and this card follows, no layout change needed.
class SuggestionTermsCard extends StatelessWidget {
  const SuggestionTermsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: AppConstants.iconSm,
                color: AppColors.gold,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                AppStrings.suggestionTermsTitle,
                style: AppTextStyles.caption.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ...AppStrings.suggestionTerms.map(
                (term) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.goldDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(
                      term,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}