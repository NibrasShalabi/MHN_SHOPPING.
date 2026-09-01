import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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
      decoration: InputDecoration(
        hintText: hint ?? 'Search',
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: (controller?.text.isNotEmpty ?? false)
            ? IconButton(icon: const Icon(Icons.close), onPressed: onClear)
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppConstants.spacingMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
