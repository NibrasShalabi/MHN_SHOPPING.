import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/entry_banner.dart';

/// Entry to the fitness section. Visibility (women only) is decided by the
/// caller — this widget makes no gender decision of its own.
class FitnessEntryBanner extends StatelessWidget {
  static const double _emblem = 118;

  final VoidCallback onTap;

  const FitnessEntryBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return EntryBanner(
      onTap: onTap,
      art: Container(
        width: _emblem,
        height: _emblem,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.45), blurRadius: 22, spreadRadius: 1)],
        ),
        child: Image.asset('assets/images/fitness_emblem.png', filterQuality: FilterQuality.medium),
      ),
      tagIcon: Icons.spa_outlined,
      tag: AppStrings.fitnessBannerTag,
      title: AppStrings.fitnessBannerTitle,
      body: AppStrings.fitnessBannerBody,
      button: AppStrings.discoverSection,
    );
  }
}
