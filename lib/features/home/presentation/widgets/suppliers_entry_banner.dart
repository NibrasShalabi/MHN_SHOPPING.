import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Entry to the suppliers section, under the fire-deals banner.
///
/// Built like a shop sign: a polished-gold rim with a fine inner frame, the
/// storefront art melting into a wine backdrop on one side, the copy on the
/// other. Calmer than the fire-deals banner so the two don't compete.
class SuppliersEntryBanner extends StatelessWidget {
  static const String _art = 'assets/images/suppliers.jpg';
  static const double _height = 172;
  static const double _rim = 1.4;
  static const double _artWidth = 170;

  /// The copy may run over the faded part of the art, not the solid part.
  static const double _copyEnd = _artWidth * 0.55;

  final VoidCallback onTap;

  const SuppliersEntryBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final outer = BorderRadius.circular(AppConstants.radiusLg);
    final inner = BorderRadius.circular(AppConstants.radiusLg - _rim);

    return DecoratedBox(
      // Gold rim + soft ember glow underneath.
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: outer,
        boxShadow: [
          BoxShadow(color: AppColors.ember.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_rim),
        child: ClipRRect(
          borderRadius: inner,
          child: Material(
            color: AppColors.surfaceWine,
            child: InkWell(
              onTap: onTap,
              splashColor: AppColors.gold.withValues(alpha: 0.12),
              highlightColor: AppColors.gold.withValues(alpha: 0.05),
              child: SizedBox(
                height: _height,
                child: Stack(
                  children: [
                    const Positioned.fill(child: _Backdrop()),
                    const PositionedDirectional(top: 0, bottom: 0, end: 0, child: _StorefrontArt(width: _artWidth)),
                    // Fine inner frame, like the shop-sign moulding.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          margin: const EdgeInsets.all(AppConstants.spacingXs + 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.28), width: AppConstants.borderThin),
                          ),
                        ),
                      ),
                    ),
                    const PositionedDirectional(top: 14, end: _artWidth - 6, child: _Sparkle(size: 12)),
                    const PositionedDirectional(bottom: 22, end: _artWidth * 0.5, child: _Sparkle(size: 8)),
                    const PositionedDirectional(
                      top: 0,
                      bottom: 0,
                      start: AppConstants.spacingLg,
                      end: _copyEnd,
                      child: _Copy(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wine-to-coal sweep with a warm glow behind the storefront.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: rtl ? Alignment.centerRight : Alignment.centerLeft,
          end: rtl ? Alignment.centerLeft : Alignment.centerRight,
          colors: const [AppColors.surfaceDark, AppColors.surfaceWine, AppColors.emberDeep],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: rtl ? const Alignment(-0.65, -0.2) : const Alignment(0.65, -0.2),
            radius: 0.9,
            colors: [AppColors.flame.withValues(alpha: 0.22), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

/// The storefront, faded out toward the copy so it blends instead of sitting in a box.
class _StorefrontArt extends StatelessWidget {
  final double width;

  const _StorefrontArt({required this.width});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => LinearGradient(
        // Transparent on the side facing the text, solid on the outer edge.
        begin: rtl ? Alignment.centerRight : Alignment.centerLeft,
        end: rtl ? Alignment.centerLeft : Alignment.centerRight,
        colors: const [Colors.transparent, Colors.black, Colors.black],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(rect),
      child: Image.asset(
        SuppliersEntryBanner._art,
        width: width,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _Copy extends StatelessWidget {
  const _Copy();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_outlined, size: AppConstants.iconSm - 2, color: AppColors.goldLight),
            const SizedBox(width: AppConstants.spacingXs),
            Text(
              AppStrings.suppliersBannerTag,
              style: AppTextStyles.caption.copyWith(color: AppColors.goldLight, letterSpacing: 0.6),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingXs),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => AppColors.goldGradient.createShader(rect),
          child: Text(
            AppStrings.suppliersBannerTitle,
            style: AppTextStyles.heading1.copyWith(
              fontFamily: 'ArefRuqaa',
              fontWeight: FontWeight.bold,
              height: 1.1,
              shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2))],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          AppStrings.suppliersBannerBody,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.8), height: 1.5),
        ),
        const SizedBox(height: AppConstants.spacingSm + 2),
        const _GoldButton(label: AppStrings.browseSuppliers),
      ],
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;

  const _GoldButton({required this.label});

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
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.surfaceDark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: AppConstants.spacingXs),
          const Icon(Icons.arrow_forward_rounded, size: AppConstants.iconSm, color: AppColors.surfaceDark),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double size;

  const _Sparkle({required this.size});

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.auto_awesome, size: size, color: AppColors.goldLight.withValues(alpha: 0.75));
}
