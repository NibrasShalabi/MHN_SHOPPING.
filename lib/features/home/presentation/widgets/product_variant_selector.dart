import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product_variants.dart';
import 'size_guide_sheet.dart';

/// Size and colour pickers for the details page.
///
/// Rendered only when the admin actually set variants on the product, so a
/// shampoo shows nothing and a jacket shows both — no empty rows.
class ProductVariantSelector extends StatelessWidget {
  final List<String> sizes;
  final List<ProductColor> colors;
  final List<SizeGuideRow> sizeGuide;

  final String? selectedSize;
  final ProductColor? selectedColor;

  final ValueChanged<String> onSizeSelected;
  final ValueChanged<ProductColor> onColorSelected;

  const ProductVariantSelector({
    super.key,
    required this.sizes,
    required this.colors,
    required this.sizeGuide,
    required this.selectedSize,
    required this.selectedColor,
    required this.onSizeSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasSizes = sizes.isNotEmpty;
    if (!hasSizes && colors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasSizes) ...[
          _SectionHeader(
            title: AppStrings.size,
            // The guide button lives next to the sizes because that's
            // where the doubt is — a separate section further down gets
            // scrolled past.
            trailing: sizeGuide.isEmpty
                ? null
                : _SizeGuideButton(
              onTap: () => showSizeGuideSheet(context, sizeGuide),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: [
              for (final size in sizes)
                _Pill(label: size, isSelected: size == selectedSize, onTap: () => onSizeSelected(size)),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
        ],
        if (colors.isNotEmpty) ...[
          _SectionHeader(title: AppStrings.color),
          const SizedBox(height: AppConstants.spacingSm),
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: colors
                .map(
                  (color) => _ColorSwatch(
                color: color,
                isSelected: color == selectedColor,
                onTap: () => onColorSelected(color),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: AppConstants.spacingLg),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
        if (trailing != null) ...[
          const SizedBox(width: AppConstants.spacingSm),
          trailing!,
        ],
      ],
    );
  }
}

class _SizeGuideButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SizeGuideButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.straighten,
              size: AppConstants.iconSm,
              color: AppColors.iconPrimary,
            ),
            const SizedBox(width: AppConstants.spacingXs),
            Text(
              AppStrings.sizeGuide,
              style: AppTextStyles.caption.copyWith(color: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Pill({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppConstants.minTouchTarget,
          minHeight: AppConstants.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: AppConstants.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? AppColors.goldLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final ProductColor color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: SizedBox(
        // Full touch target even though the swatch itself is smaller.
        height: AppConstants.minTouchTarget,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppConstants.colorSwatchSize,
              height: AppConstants.colorSwatchSize,
              decoration: BoxDecoration(
                color: Color(color.value),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppColors.border,
                  width: isSelected ? AppConstants.borderThick : AppConstants.borderThin,
                ),
              ),
              child: isSelected
                  // Dark tick on light swatches, light on dark — readable on any colour.
                  ? Icon(Icons.check,
                      size: AppConstants.iconSm,
                      color: Color(color.value).computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
                  : null,
            ),
            const SizedBox(width: AppConstants.spacingXs),
            Text(
              color.name,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.goldLight : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
          ],
        ),
      ),
    );
  }
}