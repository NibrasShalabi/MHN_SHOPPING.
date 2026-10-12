import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Scrollbars across the app as a thin fire cord: a scarlet thumb with a
/// gold edge on a coal track. Only where the platform shows scrollbars
/// (web and desktop); phones keep their native overscroll.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    if (getPlatform(context) case TargetPlatform.android || TargetPlatform.iOS) return child;
    // Swipers and horizontal rows don't need a bar under them.
    if (axisDirectionToAxis(details.direction) != Axis.vertical) return child;
    return RawScrollbar(
      controller: details.controller,
      thickness: 7,
      thumbColor: AppColors.scarlet,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.goldLight, width: 1)),
      trackVisibility: true,
      trackColor: AppColors.surfaceDark,
      trackBorderColor: AppColors.gold.withValues(alpha: 0.18),
      trackRadius: const Radius.circular(8),
      crossAxisMargin: 2,
      mainAxisMargin: 4,
      interactive: true,
      child: child,
    );
  }
}
