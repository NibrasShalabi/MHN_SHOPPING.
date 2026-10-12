import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gold_frame.dart';
import '../../domain/entities/product.dart';
import 'price_text.dart';

/// A product in a grid, in the same gold-and-fire family as the cart lines
/// and home banners.
class ProductCard extends StatelessWidget {
  final Product product;
  final bool showNewBadge;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, required this.showNewBadge, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GoldFrame(
      radius: AppConstants.radiusMd,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXs + 2),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Picture(url: product.thumbnailUrl),
                  if (showNewBadge)
                    const PositionedDirectional(
                      top: AppConstants.spacingXs,
                      start: AppConstants.spacingXs,
                      child: _Pill(label: AppStrings.newBadge, gold: true),
                    ),
                  if (product.hasActiveDiscount)
                    PositionedDirectional(
                      top: AppConstants.spacingXs,
                      end: AppConstants.spacingXs,
                      child: _Pill(label: '-${product.discountPercentage!.toStringAsFixed(0)}%'),
                    ),
                  if (!product.isInStock)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                        alignment: Alignment.center,
                        child: Text(AppStrings.outOfStock, style: AppTextStyles.caption.copyWith(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingSm,
              0,
              AppConstants.spacingSm,
              AppConstants.spacingSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: AppColors.goldLight, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                PriceText(
                  product: product,
                  style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.w800),
                  discountColor: AppColors.goldLight,
                  strikeColor: AppColors.textOnPrimary.withValues(alpha: 0.6),
                ),
                if (product.isLowStock) ...[
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    AppStrings.lowStockCount(product.stock),
                    style: AppTextStyles.caption.copyWith(color: AppColors.goldLight),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The photo in a thin gold ring; a bag icon until images arrive.
class _Picture extends StatelessWidget {
  final String? url;

  const _Picture({required this.url});

  @override
  Widget build(BuildContext context) {
    const placeholder = Center(child: Icon(Icons.shopping_bag_outlined, color: AppColors.gold, size: AppConstants.iconLg));
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm - 1.5),
        child: ColoredBox(
          color: AppColors.surfaceDark,
          child: url == null || url!.isEmpty
              ? placeholder
              : Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool gold;

  const _Pill({required this.label, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm, vertical: 2),
      decoration: BoxDecoration(
        gradient: gold ? AppColors.goldGradient : null,
        color: gold ? null : AppColors.scarlet,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.goldLight, width: AppConstants.borderThin),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: gold ? AppColors.surfaceDark : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
