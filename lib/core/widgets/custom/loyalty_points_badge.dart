import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../constants/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Loyalty balance pill, sat beside the wordmark.
///
/// Counts up to the new value rather than snapping; a zero balance gets a
/// small bounce instead. The flame icon ties it to the phoenix identity —
/// a generic star would read as a rating, which is a different thing in a
/// shop.
class LoyaltyPointsBadge extends StatelessWidget {
  final int points;
  final VoidCallback? onTap;

  const LoyaltyPointsBadge({super.key, required this.points, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
        child: Padding(
          // Nudged down to sit on the wordmark's first line rather than
          // the centre of its two — optical alignment, since the logo's
          // second line pulls its visual centre lower than the badge's.
          padding: const EdgeInsets.only(
            left: AppConstants.spacingSm,
            right: AppConstants.spacingSm,
            top: AppConstants.spacingXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                size: AppConstants.iconMd,
                color: AppColors.gold,
              ),
              const SizedBox(width: AppConstants.spacingXs),
              points == 0
                  ? const _ZeroBounce()
                  : TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: points),
                duration: AppDurations.slow,
                builder: (context, value, _) => Text(
                  '$value',
                  style: AppTextStyles.body.copyWith(color: AppColors.goldLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZeroBounce extends StatefulWidget {
  const _ZeroBounce();

  @override
  State<_ZeroBounce> createState() => _ZeroBounceState();
}

class _ZeroBounceState extends State<_ZeroBounce> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow);
    _scale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Text('0', style: AppTextStyles.body.copyWith(color: AppColors.goldLight)),
    );
  }
}