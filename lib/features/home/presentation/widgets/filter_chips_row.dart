import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_durations.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product_filter.dart';

/// Horizontal, single-select filter row. Chip sizes are driven by their
/// text, so they grow with the system text scale instead of clipping.
class FilterChipsRow extends StatelessWidget {
  final List<ProductFilter> filters;
  final String? selectedFilterId;
  final ValueChanged<String?> onFilterSelected;

  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.selectedFilterId,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      child: Row(
        children: [
          _Chip(
            label: AppStrings.filterAll,
            isSelected: selectedFilterId == null,
            onTap: () => onFilterSelected(null),
          ),
          ...filters.map(
                (filter) => _Chip(
              label: filter.name,
              isSelected: filter.id == selectedFilterId,
              onTap: () => onFilterSelected(filter.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.spacingSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.border,
              width: AppConstants.borderThin,
            ),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: AppDurations.fast,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? AppColors.goldLight : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}