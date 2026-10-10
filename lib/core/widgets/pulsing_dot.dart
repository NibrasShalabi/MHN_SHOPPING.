import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// "There's something new here" — a red pill with a ring that keeps
/// rippling out, optionally labelled.
class PulsingDot extends StatefulWidget {
  final String? label;
  final Color color;

  const PulsingDot({super.key, this.label, this.color = AppColors.error});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final core = Container(
      padding: label == null
          ? const EdgeInsets.all(5)
          : const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm, vertical: 2),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.textOnPrimary, width: 1.5),
      ),
      child: label == null
          ? null
          : Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold)),
    );

    return AnimatedBuilder(
      animation: _controller,
      child: core,
      builder: (context, child) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            boxShadow: [
              BoxShadow(color: widget.color.withValues(alpha: 0.6 * (1 - t)), spreadRadius: 8 * t),
            ],
          ),
          child: child,
        );
      },
    );
  }
}
