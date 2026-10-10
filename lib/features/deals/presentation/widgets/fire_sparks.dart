import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Embers rising through the banner. Positions are a pure function of the
/// animation value, so the painter allocates nothing per frame; it sits in
/// its own repaint boundary and stops when [active] is false or the system
/// asks for reduced motion.
class FireSparks extends StatefulWidget {
  final bool active;

  const FireSparks({super.key, required this.active});

  @override
  State<FireSparks> createState() => _FireSparksState();
}

class _FireSparksState extends State<FireSparks> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(FireSparks old) {
    super.didUpdateWidget(old);
    _sync();
  }

  bool get _running => widget.active && !MediaQuery.disableAnimationsOf(context);

  void _sync() {
    if (_running && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_running && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_running) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _SparksPainter(_controller), size: Size.infinite),
      ),
    );
  }
}

class _SparksPainter extends CustomPainter {
  static const int _count = 16;
  static const List<Color> _colors = [AppColors.goldLight, AppColors.gold, AppColors.accent];

  final Animation<double> progress;
  final Paint _paint = Paint();

  _SparksPainter(this.progress) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < _count; i++) {
      // Each ember has a fixed lane, speed and phase derived from its index.
      final seed = (i * 0.618034) % 1;
      final t = (progress.value * (0.7 + seed * 0.6) + seed) % 1;
      final x = size.width * ((i + 0.5) / _count) + math.sin((t + seed) * math.pi * 4) * 6;
      final y = size.height * (1 - t);
      final fade = math.sin(t * math.pi); // in at the bottom, out at the top
      final radius = 1.2 + seed * 1.8;

      _paint
        ..color = _colors[i % _colors.length].withValues(alpha: 0.75 * fade)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius);
      canvas.drawCircle(Offset(x, y), radius, _paint);
    }
  }

  @override
  bool shouldRepaint(_SparksPainter old) => false;
}
