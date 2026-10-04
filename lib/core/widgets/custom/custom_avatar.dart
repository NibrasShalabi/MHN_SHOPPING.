import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double? size;
  final Color? backgroundColor;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 44.0;
    return CircleAvatar(
      radius: s / 2,
      backgroundColor: backgroundColor ?? AppColors.primary.withOpacity(0.15),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              initials ?? '?',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: s / 2.6),
            )
          : null,
    );
  }
}
