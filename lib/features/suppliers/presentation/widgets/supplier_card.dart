import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gold_frame.dart';
import '../../domain/entities/supplier.dart';
import 'supplier_visuals.dart';

/// A supplier as a shop sign: storefront cover, the logo medallion sitting
/// on its edge, the calligraphic name in gold and a gold "browse" button.
class SupplierCard extends StatelessWidget {
  static const double height = 372;
  static const double _cover = 150;
  static const double _logo = 78;

  final Supplier supplier;
  final VoidCallback onTap;

  const SupplierCard({super.key, required this.supplier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GoldFrame(
      onTap: onTap,
      fill: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.surfaceDark, AppColors.surfaceDark, AppColors.emberDeep],
        stops: [0.0, 0.6, 1.0],
      ),
      child: Stack(
        children: [
          SupplierCover(supplier: supplier, height: _cover),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: _cover - _logo / 2),
              Center(child: SupplierMonogram(supplier: supplier, size: _logo)),
              const SizedBox(height: AppConstants.spacingSm),
              const Center(child: SupplierChip(icon: Icons.verified_outlined, label: AppStrings.suppliersBannerTag)),
              const SizedBox(height: AppConstants.spacingXs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
                child: GoldText(
                  supplier.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1.copyWith(
                    fontFamily: 'ArefRuqaa',
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                ),
              ),
              if (supplier.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
                  child: Text(
                    supplier.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.85), height: 1.5),
                  ),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingMd,
                  0,
                  AppConstants.spacingMd,
                  AppConstants.spacingMd,
                ),
                child: Row(
                  children: [
                    if (supplier.address.isNotEmpty)
                      Expanded(child: SupplierChip(icon: Icons.place_outlined, label: supplier.address))
                    else
                      const Spacer(),
                    const SizedBox(width: AppConstants.spacingSm),
                    const _BrowseButton(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrowseButton extends StatelessWidget {
  const _BrowseButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd, vertical: AppConstants.spacingXs + 2),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.browseStore,
            style: AppTextStyles.caption.copyWith(color: AppColors.surfaceDark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: AppConstants.spacingXs),
          const Icon(Icons.arrow_forward_rounded, size: AppConstants.iconSm, color: AppColors.surfaceDark),
        ],
      ),
    );
  }
}
