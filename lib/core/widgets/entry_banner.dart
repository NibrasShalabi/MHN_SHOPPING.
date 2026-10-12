import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gold_frame.dart';

/// A home-screen section entry, built like a shop sign: gold rim, fire
/// backdrop, a fine inner frame, art on the end side and the copy on the
/// start side. Suppliers, fire deals and fitness all use it so they read as
/// one family.
class EntryBanner extends StatelessWidget {
  static const double height = 172;

  final Widget art;
  final double artWidth;

  /// Fades the art into the backdrop (photos); emblems sit as they are.
  final bool fadeArt;
  final IconData tagIcon;
  final String tag;
  final String title;
  final String body;
  final bool highlightBody;
  final String button;
  final VoidCallback onTap;

  /// Drawn behind everything inside the frame (e.g. rising embers).
  final Widget? backdrop;

  /// Pinned above the top edge (e.g. a "جديد" pill).
  final Widget? badge;

  const EntryBanner({
    super.key,
    required this.art,
    required this.tagIcon,
    required this.tag,
    required this.title,
    required this.body,
    required this.button,
    required this.onTap,
    this.artWidth = 150,
    this.fadeArt = false,
    this.highlightBody = false,
    this.backdrop,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final copyEnd = fadeArt ? artWidth * 0.55 : artWidth;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GoldFrame(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                if (backdrop case final b?) Positioned.fill(child: b),
                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  end: 0,
                  width: artWidth,
                  child: fadeArt ? _Faded(child: art) : Center(child: art),
                ),
                const Positioned.fill(child: IgnorePointer(child: _InnerFrame())),
                PositionedDirectional(top: 14, end: artWidth - 6, child: const _Sparkle(size: 12)),
                PositionedDirectional(bottom: 22, end: artWidth * 0.5, child: const _Sparkle(size: 8)),
                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  start: AppConstants.spacingLg,
                  end: copyEnd,
                  child: _Copy(banner: this),
                ),
              ],
            ),
          ),
        ),
        if (badge case final b?) PositionedDirectional(top: -AppConstants.spacingSm, end: AppConstants.spacingMd, child: b),
      ],
    );
  }
}

class _InnerFrame extends StatelessWidget {
  const _InnerFrame();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(AppConstants.spacingXs + 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.35), width: AppConstants.borderThin),
        ),
      );
}

/// Transparent toward the copy, solid on the outer edge.
class _Faded extends StatelessWidget {
  final Widget child;

  const _Faded({required this.child});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => LinearGradient(
        begin: rtl ? Alignment.centerRight : Alignment.centerLeft,
        end: rtl ? Alignment.centerLeft : Alignment.centerRight,
        colors: const [Colors.transparent, Colors.black, Colors.black],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(rect),
      child: child,
    );
  }
}

class _Copy extends StatelessWidget {
  final EntryBanner banner;

  const _Copy({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(banner.tagIcon, size: AppConstants.iconSm - 2, color: AppColors.goldLight),
            const SizedBox(width: AppConstants.spacingXs),
            Text(banner.tag, style: AppTextStyles.caption.copyWith(color: AppColors.goldLight, letterSpacing: 0.6)),
          ],
        ),
        const SizedBox(height: AppConstants.spacingXs),
        GoldText(
          banner.title,
          style: AppTextStyles.heading1.copyWith(
            fontFamily: 'ArefRuqaa',
            fontWeight: FontWeight.bold,
            height: 1.1,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2))],
          ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          banner.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            color: banner.highlightBody ? AppColors.goldLight : AppColors.textOnPrimary.withValues(alpha: 0.9),
            fontWeight: banner.highlightBody ? FontWeight.bold : null,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm + 2),
        _GoldButton(label: banner.button),
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
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.surfaceDark, fontWeight: FontWeight.bold)),
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
