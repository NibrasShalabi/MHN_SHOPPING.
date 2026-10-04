import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Gold hairline under the app bar, fading out toward the edges.
///
/// A flat wine bar reads as unfinished against the darker page behind it;
/// this gives it a defined edge without a heavy solid rule. Shared so the
/// header looks identical on every screen.
class AppBarBottomBorder extends StatelessWidget implements PreferredSizeWidget {
  const AppBarBottomBorder({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarBorderHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.appBarBorderHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.transparent,
            AppColors.goldDark,
            AppColors.gold,
            AppColors.goldDark,
            Colors.transparent,
          ],
          stops: [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }
}