import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Two-line brand wordmark: "MHN" over "Shopping".
///
/// The mark is painted through a fire gradient rather than a flat colour —
/// yellow at the top through orange into red, the way a flame reads from
/// its hottest point outward.
///
/// [large] switches to the oversized cut used on the splash and in hero
/// blocks; [glow] adds the halo behind it (splash only — it would be noise
/// in an app bar).
class AppLogo extends StatelessWidget {
  final bool large;
  final bool glow;

  const AppLogo({super.key, this.large = false, this.glow = false});

  static const List<Shadow> _glowShadows = [
    Shadow(color: AppColors.flame, blurRadius: 26),
    Shadow(color: AppColors.scarlet, blurRadius: 48),
  ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = large ? AppTextStyles.logoLarge : AppTextStyles.logo;
    final subStyle = large ? AppTextStyles.logoSubLarge : AppTextStyles.logoSub;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: large ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _GradientText(
          AppStrings.logoLine1,
          // Shadows have to be drawn under the mask, not on the masked
          // result, or the gradient tints the halo too.
          style: glow ? titleStyle.copyWith(shadows: _glowShadows) : titleStyle,
        ),
        Padding(
          // The script's descenders already eat into the gap, so the two
          // lines are pulled together rather than spaced apart.
          padding: EdgeInsets.only(top: large ? 0 : 2),
          child: _GradientText(AppStrings.logoLine2, style: subStyle),
        ),
      ],
    );
  }
}

/// Paints text through [AppColors.logoGradient].
///
/// ShaderMask needs real bounds to map the gradient onto, which is why the
/// gradient is created from the reported rect rather than a fixed size —
/// otherwise the two lines would each get their own full ramp and stop
/// matching.
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _GradientText(this.text, {required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppColors.logoGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}