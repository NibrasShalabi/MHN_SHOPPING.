import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.body.copyWith(color: AppColors.gold),
      decoration: InputDecoration(
        hintText: hint ?? 'Search',
        hintStyle: AppTextStyles.body,
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: const Icon(Icons.search, color: AppColors.flame),
        suffixIcon: (controller?.text.isNotEmpty ?? false)
            ? IconButton(
          icon: const Icon(Icons.close, color: AppColors.flame),
          onPressed: onClear,
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppConstants.spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
    );
  }
}