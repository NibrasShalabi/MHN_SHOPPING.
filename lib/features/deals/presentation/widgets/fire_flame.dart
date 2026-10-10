import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The banner's 🔥 — breathes with a warm glow while deals are live,
/// rests still when there are none.
class FireFlame extends StatefulWidget {
  final bool live;
  final double size;

  const FireFlame({super.key, required this.live, this.size = 56});

  @override
  State<FireFlame> createState() => _FireFlameState();
}

class _FireFlameState extends State<FireFlame> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(FireFlame old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.live && !MediaQuery.disableAnimationsOf(context);
    if (run && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!run && _controller.isAnimating) {
      _controller.animateTo(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flame = Text('🔥', style: TextStyle(fontSize: widget.size));
    return AnimatedBuilder(
      animation: _controller,
      child: flame,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: widget.live ? 0.25 + 0.3 * t : 0),
                blurRadius: 18 + 14 * t,
                spreadRadius: 2 * t,
              ),
            ],
          ),
          child: Transform.scale(scale: 1 + 0.08 * t, child: child),
        );
      },
    );
  }
}
