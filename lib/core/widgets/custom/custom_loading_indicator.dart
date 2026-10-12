import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The app's loader: a flame breathing inside a gold ring that sweeps
/// around it like a spark chasing its tail. [color] and [strokeWidth] are
/// kept so existing call sites compile; the look is the brand's.
class CustomLoadingIndicator extends StatefulWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const CustomLoadingIndicator({super.key, this.size, this.color, this.strokeWidth});

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 56;
    return Center(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              // Two breaths per turn of the ring.
              final breath = 0.5 + 0.5 * math.sin(t * math.pi * 4);
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Warm glow behind the flame.
                  Container(
                    width: size * 0.62,
                    height: size * 0.62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.flame.withValues(alpha: 0.25 + 0.3 * breath),
                          blurRadius: size * 0.35,
                          spreadRadius: size * 0.02,
                        ),
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: t * 2 * math.pi,
                    child: CustomPaint(size: Size.square(size), painter: _RingPainter()),
                  ),
                  Transform.scale(
                    scale: 0.9 + 0.12 * breath,
                    child: Text('🔥', style: TextStyle(fontSize: size * 0.42, height: 1)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A faint full ring with a bright gold-to-fire arc running round it.
class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = math.max(2.5, size.width * 0.06);
    final rect = Offset.zero & size;
    final circle = rect.deflate(stroke / 2);

    canvas.drawArc(
      circle,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.gold.withValues(alpha: 0.15),
    );

    canvas.drawArc(
      circle,
      0,
      math.pi * 1.35,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [Colors.transparent, AppColors.ember, AppColors.flame, AppColors.goldLight],
          stops: [0.0, 0.25, 0.55, 0.75],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => false;
}
