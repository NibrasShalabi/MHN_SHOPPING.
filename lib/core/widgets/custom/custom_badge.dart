import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomBadge extends StatelessWidget {
  final Widget child;
  final int? count;
  final Color? color;
  final bool showZero;

  const CustomBadge({
    super.key,
    required this.child,
    this.count,
    this.color,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShow = count != null && (count! > 0 || showZero);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (shouldShow)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(color: color ?? AppColors.error, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
