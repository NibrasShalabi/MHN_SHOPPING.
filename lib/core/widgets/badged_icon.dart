import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// An icon with a count bubble in its corner; nothing extra when [count] is 0.
class BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color badgeColor;
  final Color textColor;

  const BadgedIcon({
    super.key,
    required this.icon,
    required this.count,
    this.badgeColor = AppColors.error,
    this.textColor = AppColors.textOnPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: AppConstants.iconMd, color: AppColors.iconPrimary),
        if (count > 0)
          PositionedDirectional(
            top: -4,
            end: -6,
            child: CountBubble(count: count, color: badgeColor, textColor: textColor),
          ),
      ],
    );
  }
}

/// "3", or "9+" past nine.
class CountBubble extends StatelessWidget {
  final int count;
  final Color color;
  final Color textColor;

  const CountBubble({super.key, required this.count, this.color = AppColors.error, this.textColor = AppColors.textOnPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
      child: Text(
        count > 9 ? '9+' : '$count',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
