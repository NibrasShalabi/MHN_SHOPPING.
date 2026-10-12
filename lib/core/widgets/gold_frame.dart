import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// The premium card shell: a polished-gold rim, an ember glow underneath and
/// the fire backdrop inside. Banners, cart lines and product cards share it.
class GoldFrame extends StatelessWidget {
  static const double rim = 1.4;

  final Widget child;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? fill;
  final bool muted;

  const GoldFrame({
    super.key,
    required this.child,
    this.radius = AppConstants.radiusLg,
    this.onTap,
    this.fill = AppColors.emberBackdrop,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: muted ? null : AppColors.goldGradient,
        color: muted ? AppColors.border : null,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          if (!muted) BoxShadow(color: AppColors.ember.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(rim),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - rim),
          child: Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: BoxDecoration(gradient: muted ? null : fill, color: muted ? AppColors.surfaceDark : null),
              child: InkWell(
                onTap: onTap,
                splashColor: AppColors.gold.withValues(alpha: 0.12),
                highlightColor: AppColors.gold.withValues(alpha: 0.05),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text painted with the gold gradient.
class GoldText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const GoldText(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: AppColors.goldGradient.createShader,
        child: Text(text, style: style),
      );
}
