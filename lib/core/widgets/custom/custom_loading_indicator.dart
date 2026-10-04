import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const CustomLoadingIndicator({super.key, this.size, this.color, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 28,
        height: size ?? 28,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 2.5,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}
