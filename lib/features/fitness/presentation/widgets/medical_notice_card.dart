import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/surface_card.dart';

/// Explains why health questions are asked, or that supplements are
/// display-only.
///
/// Deliberately prominent rather than fine print: the user is being asked
/// for medical details, and telling them who sees the data and why is what
/// makes that reasonable to ask.
class MedicalNoticeCard extends StatelessWidget {
  final String message;
  final IconData icon;

  const MedicalNoticeCard({
    super.key,
    required this.message,
    this.icon = Icons.health_and_safety_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      borderColor: AppColors.gold,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppConstants.iconMd, color: AppColors.gold),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}