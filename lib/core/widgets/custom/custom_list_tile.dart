import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const CustomListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary))
          : null,
    );
  }
}
