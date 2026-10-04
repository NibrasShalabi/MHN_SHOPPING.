import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSm)),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel != null ? itemLabel!(item) : item.toString()),
              ))
          .toList(),
    );
  }
}
