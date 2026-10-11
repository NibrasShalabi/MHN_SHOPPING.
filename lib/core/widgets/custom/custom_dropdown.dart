import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String Function(T)? itemLabel;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    final r = AppConstants.radiusSm;
    return DropdownButtonFormField<T>(
      key: ValueKey(value), // initialValue only applies once; a new value rebuilds it
      initialValue: value,
      onChanged: onChanged,
      style: AppTextStyles.body.copyWith(color: AppColors.gold),
      dropdownColor: AppColors.surface,
      iconEnabledColor: AppColors.gold,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r),
          borderSide: const BorderSide(color: AppColors.gold, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(r),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(
          itemLabel != null ? itemLabel!(item) : item.toString(),
          style: AppTextStyles.body.copyWith(color: AppColors.gold),
        ),
      ))
          .toList(),
    );
  }
}