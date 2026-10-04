import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../widgets/about_hero.dart';
import '../widgets/about_info_card.dart';
import '../widgets/about_section_title.dart';

/// Static content screen — no cubit, no repository.
///
/// TODO(logic-phase): the admin dashboard is meant to edit this copy, so
/// the strings move behind an AboutCubit + repository then. The layout
/// here doesn't change when that happens: only where the text comes from.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        bottom: const AppBarBottomBorder(),
        centerTitle: true,
        title: Text(AppStrings.aboutUs, style: AppTextStyles.heading2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AboutHero(),
            const SizedBox(height: AppConstants.spacingXl),

            const AboutSectionTitle(title: AppStrings.ourVision),
            const SizedBox(height: AppConstants.spacingMd),
            const AboutInfoCard(
              body: AppStrings.ourVisionBody,
            ),
            const SizedBox(height: AppConstants.spacingXl),

            const AboutSectionTitle(title: AppStrings.ourMission),
            const SizedBox(height: AppConstants.spacingMd),
            const AboutInfoCard(
              body: AppStrings.ourMissionBody,
            ),
            const SizedBox(height: AppConstants.spacingXl),

            const AboutSectionTitle(title: AppStrings.ourGoal),
            const SizedBox(height: AppConstants.spacingMd),
            const AboutInfoCard(
              body: AppStrings.ourGoalBody,
            ),
            const SizedBox(height: AppConstants.spacingXl),

            const AboutSectionTitle(title: AppStrings.ourSlogan),
            const SizedBox(height: AppConstants.spacingMd),
            const AboutInfoCard(
              body: AppStrings.ourSloganBody,
            ),
            const SizedBox(height: AppConstants.spacingXl),

            const AboutSectionTitle(title: AppStrings.productsSource),
            const SizedBox(height: AppConstants.spacingMd),
            const AboutInfoCard(
              body: AppStrings.productsSourceBody,
            ),
            const SizedBox(height: AppConstants.spacingXl),

            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }
}

