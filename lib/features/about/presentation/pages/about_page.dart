import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../widgets/about_goal_card.dart';
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

  static const List<_Goal> _goals = [
    _Goal(Icons.verified_outlined, AppStrings.goalQuality, AppStrings.goalQualityBody),
    _Goal(Icons.sell_outlined, AppStrings.goalPrice, AppStrings.goalPriceBody),
    _Goal(Icons.local_shipping_outlined, AppStrings.goalDelivery, AppStrings.goalDeliveryBody),
    _Goal(Icons.support_agent_outlined, AppStrings.goalSupport, AppStrings.goalSupportBody),
  ];

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

            const AboutSectionTitle(title: AppStrings.ourMission),
            const SizedBox(height: AppConstants.spacingMd),
            const AboutInfoCard(
              icon: Icons.auto_awesome_outlined,
              body: AppStrings.ourMissionBody,
            ),
            const SizedBox(height: AppConstants.spacingXl),

            const AboutSectionTitle(title: AppStrings.ourGoals),
            const SizedBox(height: AppConstants.spacingMd),
            LayoutBuilder(
              builder: (context, constraints) {
                // Two columns on a normal phone, more on wider screens —
                // the cards size to their text, so nothing clips when the
                // user raises the system font size.
                final columns =
                (constraints.maxWidth / AppConstants.goalCardMinWidth).floor().clamp(1, 4);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _goals.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppConstants.spacingSm,
                    mainAxisSpacing: AppConstants.spacingSm,
                    mainAxisExtent: AppConstants.goalCardHeight,
                  ),
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    return AboutGoalCard(
                      icon: goal.icon,
                      title: goal.title,
                      body: goal.body,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: AppConstants.spacingXl),

            const AboutSectionTitle(title: AppStrings.productsSource),
            const SizedBox(height: AppConstants.spacingMd),
            const AboutInfoCard(
              icon: Icons.inventory_2_outlined,
              body: AppStrings.productsSourceBody,
            ),
            const SizedBox(height: AppConstants.spacingXl),

            const _ContactCard(),
            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }
}

class _Goal {
  final IconData icon;
  final String title;
  final String body;

  const _Goal(this.icon, this.title, this.body);
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceWine,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.gold, width: AppConstants.borderThin),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.headset_mic_outlined,
            size: AppConstants.iconLg,
            color: AppColors.goldLight,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            AppStrings.contactUs,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            AppStrings.contactUsBody,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          CustomButton(
            label: AppStrings.support,
            icon: Icons.chat_bubble_outline,
            width: double.infinity,
            // TODO(support-feature): route to the support screen.
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}