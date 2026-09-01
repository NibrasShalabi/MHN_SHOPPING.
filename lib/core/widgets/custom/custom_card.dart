import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.color,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppConstants.radiusMd;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppConstants.spacingMd),
      child: child,
    );

    final card = Material(
      color: color ?? AppColors.surface,
      elevation: elevation ?? 1,
      borderRadius: BorderRadius.circular(r),
      child: onTap != null
          ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(r), child: content)
          : content,
    );

    return card;
  }
}
