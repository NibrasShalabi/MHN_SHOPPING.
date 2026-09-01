import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// The app's standard content surface: elevated background, hairline
/// border, rounded corners.
///
/// Exists because that exact decoration was repeated in a dozen widgets —
/// changing the card look meant editing every one of them, and they had
/// already started to drift apart.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;

  /// Highlight colour for the border — used for unread/active states.
  final Color? borderColor;

  /// Replaces the flat background (e.g. AppColors.fireGradient).
  final Gradient? gradient;

  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius ?? AppConstants.radiusMd);

    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.surfaceElevated : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: AppConstants.borderThin,
        ),
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: card,
    );
  }
}