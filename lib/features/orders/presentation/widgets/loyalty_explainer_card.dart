// import 'package:flutter/material.dart';
//
// import '../../../../../core/constants/app_constants.dart';
// import '../../../../../core/constants/app_strings.dart';
// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';
//
// /// Short loyalty pitch + the full list of point-earning actions.
// class LoyaltyExplainerCard extends StatelessWidget {
//   const LoyaltyExplainerCard({super.key});
//
//   static const List<_EarnRule> _rules = [
//     _EarnRule(Icons.shopping_bag_outlined, AppStrings.loyaltyEarnPurchase),
//     _EarnRule(Icons.star_outline, AppStrings.loyaltyEarnRating),
//     _EarnRule(Icons.lightbulb_outline, AppStrings.loyaltyEarnSuggestion),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(AppConstants.spacingMd),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [AppColors.primary, AppColors.primaryDark],
//         ),
//         borderRadius: BorderRadius.circular(AppConstants.radiusLg),
//         border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.star, color: AppColors.gold, size: AppConstants.iconMd),
//               const SizedBox(width: AppConstants.spacingSm),
//               Expanded(
//                 child: Text(
//                   AppStrings.loyaltyPoints,
//                   style: AppTextStyles.body.copyWith(
//                     color: AppColors.textOnPrimary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppConstants.spacingSm),
//           Text(
//             AppStrings.loyaltyIntro,
//             style: AppTextStyles.caption.copyWith(
//               color: AppColors.accentLight,
//               height: 1.7,
//             ),
//           ),
//           const SizedBox(height: AppConstants.spacingMd),
//           Text(
//             AppStrings.loyaltyHowToEarn,
//             style: AppTextStyles.caption.copyWith(color: AppColors.goldLight),
//           ),
//           const SizedBox(height: AppConstants.spacingSm),
//           ..._rules.map(
//                 (rule) => Padding(
//               padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(rule.icon, size: AppConstants.iconSm, color: AppColors.goldLight),
//                   const SizedBox(width: AppConstants.spacingSm),
//                   Expanded(
//                     child: Text(
//                       rule.label,
//                       style: AppTextStyles.caption.copyWith(
//                         color: AppColors.textOnPrimary,
//                         height: 1.6,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EarnRule {
//   final IconData icon;
//   final String label;
//
//   const _EarnRule(this.icon, this.label);
// }
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Short loyalty pitch + the full list of point-earning actions.
class LoyaltyExplainerCard extends StatelessWidget {
  const LoyaltyExplainerCard({super.key});

  static const List<_EarnRule> _rules = [
    _EarnRule(Icons.shopping_bag_outlined, AppStrings.loyaltyEarnPurchase),
    _EarnRule(Icons.star_outline, AppStrings.loyaltyEarnRating),
    _EarnRule(Icons.lightbulb_outline, AppStrings.loyaltyEarnSuggestion),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        gradient: AppColors.fireGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.gold, size: AppConstants.iconMd),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Text(
                  AppStrings.loyaltyPoints,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            AppStrings.loyaltyIntro,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accentLight,
              height: 1.7,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            AppStrings.loyaltyHowToEarn,
            style: AppTextStyles.caption.copyWith(color: AppColors.goldLight),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ..._rules.map(
                (rule) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(rule.icon, size: AppConstants.iconSm, color: AppColors.goldLight),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(
                      rule.label,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnPrimary,
                        height: 1.6,
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

class _EarnRule {
  final IconData icon;
  final String label;

  const _EarnRule(this.icon, this.label);
}