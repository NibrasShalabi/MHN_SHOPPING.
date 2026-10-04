import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/theme/app_colors.dart';

/// Tappable five-star input.
class StarRatingInput extends StatelessWidget {
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const StarRatingInput({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final star = index + 1;
        final isFilled = star <= value;

        return IconButton(
          onPressed: enabled ? () => onChanged(star) : null,
          iconSize: AppConstants.iconLg,
          // Scales up as it fills — the small kick makes tapping feel
          // deliberate rather than like a checkbox.
          icon: AnimatedScale(
            scale: isFilled ? 1.15 : 1.0,
            duration: AppDurations.fast,
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              color: isFilled ? AppColors.gold : AppColors.textDisabled,
            ),
          ),
        );
      }),
    );
  }
}