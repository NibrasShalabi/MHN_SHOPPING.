import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/supplier.dart';

/// The band behind a supplier's name: fire light falling into coal, with
/// a few sparkles — each supplier's own photo can take its place later.
class SupplierCover extends StatelessWidget {
  final Supplier supplier;
  final double height;

  const SupplierCover({super.key, required this.supplier, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: const Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.6),
                radius: 1.1,
                colors: [AppColors.flame, AppColors.scarlet, AppColors.crimson, AppColors.ember],
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x66000000), AppColors.surfaceDark],
                stops: [0.3, 0.75, 1.0],
              ),
            ),
          ),
          PositionedDirectional(top: 12, end: 16, child: _Sparkle(size: 14)),
          PositionedDirectional(top: 34, start: 22, child: _Sparkle(size: 9)),
          PositionedDirectional(top: 20, start: 90, child: _Sparkle(size: 7)),
        ],
      ),
    );
  }
}

/// The supplier's logo in a gold ring — or, until there is one, the first
/// letter of the name in the calligraphic face on a coal-and-ember disc.
class SupplierMonogram extends StatelessWidget {
  final Supplier supplier;
  final double size;

  const SupplierMonogram({super.key, required this.supplier, this.size = 76});

  @override
  Widget build(BuildContext context) {
    final logo = supplier.logoUrl;
    final letter = supplier.name.trim().isEmpty ? '؟' : supplier.name.trim().characters.first;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.goldGradient,
        boxShadow: [
          BoxShadow(color: AppColors.gold.withValues(alpha: 0.45), blurRadius: 18, spreadRadius: 1),
          const BoxShadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: ClipOval(
        child: logo != null && logo.isNotEmpty
            ? Image.network(logo, fit: BoxFit.cover, errorBuilder: (_, _, _) => _Letter(letter: letter, size: size))
            : _Letter(letter: letter, size: size),
      ),
    );
  }
}

class _Letter extends StatelessWidget {
  final String letter;
  final double size;

  const _Letter({required this.letter, required this.size});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: RadialGradient(colors: [AppColors.ember, AppColors.surfaceDark])),
      child: Center(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: AppColors.goldGradient.createShader,
          child: Text(
            letter,
            style: AppTextStyles.heading1.copyWith(fontFamily: 'ArefRuqaa', fontSize: size * 0.48, height: 1.1),
          ),
        ),
      ),
    );
  }
}

/// A small gold pill: "متجر معتمد", the area, and so on.
class SupplierChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const SupplierChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: AppConstants.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.goldLight),
          const SizedBox(width: AppConstants.spacingXs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: AppColors.goldLight, fontSize: 11.5),
            ),
          ),
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
      Icon(Icons.auto_awesome, size: size, color: AppColors.goldLight.withValues(alpha: 0.8));
}
