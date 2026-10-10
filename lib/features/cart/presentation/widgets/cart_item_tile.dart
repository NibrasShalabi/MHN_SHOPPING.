import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_amount.dart';

/// One cart line: a dark card with a gold edge and an ember glow on the
/// start side, the picture in a gold ring, the choices as chips, and the
/// total in gold next to a capsule stepper.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool isUnavailable;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    this.isUnavailable = false,
  });

  static const _radius = BorderRadius.all(Radius.circular(AppConstants.radiusLg));

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnavailable ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
        padding: const EdgeInsets.all(1.2), // gold hairline frame
        decoration: BoxDecoration(
          borderRadius: _radius,
          gradient: isUnavailable ? null : AppColors.goldGradient,
          color: isUnavailable ? AppColors.border : null,
          boxShadow: [BoxShadow(color: AppColors.ember.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: const BoxDecoration(
            borderRadius: _radius,
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: [AppColors.emberDeep, AppColors.surfaceDark, AppColors.surfaceDark],
              stops: [0, 0.45, 1],
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumb(url: item.imageUrl),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(child: _Details(item: item, isUnavailable: isUnavailable)),
                  _RoundIcon(icon: Icons.delete_outline, color: AppColors.scarlet, onTap: onRemove),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              const _GoldDivider(),
              const SizedBox(height: AppConstants.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatCartAmount(item.priceSnapshot, item.pricing)} × ${item.quantity}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        ShaderMask(
                          shaderCallback: AppColors.goldGradient.createShader,
                          child: Text(
                            formatCartAmount(item.lineTotal, item.pricing),
                            style: AppTextStyles.heading2.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isUnavailable) _Stepper(quantity: item.quantity, onIncrease: onIncrease, onDecrease: onDecrease),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;

  const _Thumb({required this.url});

  @override
  Widget build(BuildContext context) {
    const size = AppConstants.cartThumbSize;
    const placeholder = Icon(Icons.shopping_bag_outlined, color: AppColors.gold, size: AppConstants.iconLg);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.radiusMd)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppConstants.radiusMd - 2)),
        child: ColoredBox(
          color: AppColors.surface,
          child: url == null || url!.isEmpty
              ? const Center(child: placeholder)
              : Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Center(child: placeholder)),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final CartItem item;
  final bool isUnavailable;

  const _Details({required this.item, required this.isUnavailable});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(color: AppColors.goldLight, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Wrap(
          spacing: AppConstants.spacingXs,
          runSpacing: AppConstants.spacingXs,
          children: [
            if (isUnavailable) const _Chip(label: AppStrings.outOfStock, color: AppColors.error, filled: true),
            if (item.size case final size?) _Chip(icon: Icons.straighten, label: size),
            if (item.color case final c?) _Chip(swatch: Color(c.value), label: c.name),
          ],
        ),
      ],
    );
  }
}

/// A small outlined pill: a size, a colour with its swatch, or a status.
class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? swatch;
  final Color color;
  final bool filled;

  const _Chip({required this.label, this.icon, this.swatch, this.color = AppColors.gold, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.6), width: AppConstants.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 12, color: color),
          if (swatch != null)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldLight, width: 1),
              ),
            ),
          if (icon != null || swatch != null) const SizedBox(width: AppConstants.spacingXs),
          Text(label, style: AppTextStyles.caption.copyWith(color: filled ? AppColors.textOnPrimary : AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _Stepper({required this.quantity, required this.onIncrease, required this.onDecrease});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg * 2),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: AppConstants.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIcon(icon: Icons.remove, color: AppColors.goldLight, onTap: onDecrease),
          SizedBox(
            width: 34,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.w700),
            ),
          ),
          _RoundIcon(icon: Icons.add, color: AppColors.surfaceDark, background: AppColors.goldGradient, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Gradient? background;
  final VoidCallback onTap;

  const _RoundIcon({required this.icon, required this.color, required this.onTap, this.background});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: background,
          color: background == null ? color.withValues(alpha: 0.12) : null,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.gold.withValues(alpha: 0),
          AppColors.gold.withValues(alpha: 0.6),
          AppColors.gold.withValues(alpha: 0),
        ]),
      ),
    );
  }
}
