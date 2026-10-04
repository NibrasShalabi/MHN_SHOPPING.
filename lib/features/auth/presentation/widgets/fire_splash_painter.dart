import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Splash fire: a sheet covers the screen, catches in the middle, and the
/// hole eats outward in every direction until nothing is left — paper
/// burning from a point.
///
/// The hole is polar (radius per angle), not a span between two moving
/// fronts. A left/right span produces a lens shape that reads as something
/// opening; burning paper spreads in all directions at once with a ragged
/// outline, which is what the angular noise gives.
class FireSplashPainter extends CustomPainter {
  /// 0 → 1 across the whole intro. Drives the edge fire and embers.
  final double progress;

  /// 0 → 1 for the burn. How far the hole has spread from the ignition
  /// point.
  final double burnProgress;

  final List<Ember> embers;

  /// Radius multiplier per angle, around 1.0. Shapes the ragged outline.
  final List<double> edgeNoise;

  FireSplashPainter({
    required this.progress,
    required this.burnProgress,
    required this.embers,
    required this.edgeNoise,
  });

  /// Points around the outline. Enough for a torn edge, few enough that
  /// the blurred rim strokes stay affordable.
  static const int _segments = 44;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSheet(canvas, size);
    if (burnProgress > 0) _paintRim(canvas, size);
    _paintEdgeFire(canvas, size);
    _paintEmbers(canvas, size);
  }

  // ---- the burning hole --------------------------------------------------

  /// Outline of the hole, in screen coordinates.
  ///
  /// Overshoots the screen at full progress so the sheet is completely
  /// consumed rather than leaving corners behind.
  Path? _holePath(Size size) {
    if (burnProgress <= 0.001) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.longestSide * 0.78;

    // Accelerating: a flame front speeds up as it finds more fuel.
    final spread = pow(burnProgress, 1.35).toDouble() * maxRadius;

    final path = Path();
    for (var i = 0; i <= _segments; i++) {
      final angle = i / _segments * 2 * pi;
      final noise = edgeNoise[i % edgeNoise.length];

      // Flicker the outline so the tear keeps crawling instead of just
      // scaling up.
      final crawl = 1 + 0.05 * sin(progress * 14 + i * 1.3);
      final radius = spread * noise * crawl;

      // Slightly wider than tall — the screen is portrait, so a circular
      // hole clears the top and bottom long before the sides.
      final point = Offset(
        center.dx + cos(angle) * radius * 1.25,
        center.dy + sin(angle) * radius,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    return path..close();
  }

  /// The covering sheet with the hole punched out of it. Whatever sits
  /// below this painter shows through.
  void _paintSheet(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());
    canvas.drawRect(bounds, Paint()..color = AppColors.surfaceDark);

    final hole = _holePath(size);
    if (hole != null) {
      // Scorch the sheet around the tear first — a clean cut doesn't read
      // as burnt.
      canvas.drawPath(
        hole,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 30
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
      canvas.drawPath(hole, Paint()..blendMode = BlendMode.clear);
    }

    canvas.restore();
  }

  /// Glowing edge of the tear, drawn after the sheet so it isn't cleared
  /// along with it.
  void _paintRim(Canvas canvas, Size size) {
    final hole = _holePath(size);
    if (hole == null) return;

    // Fades as the hole runs off-screen — a rim still blazing at the very
    // end looks like a frame rather than a burn.
    final fade = (1 - ((burnProgress - 0.75) / 0.25)).clamp(0.0, 1.0);
    if (fade <= 0) return;

    canvas.drawPath(
      hole,
      Paint()
        ..color = AppColors.flame.withValues(alpha: 0.55 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    canvas.drawPath(
      hole,
      Paint()
        ..color = AppColors.glow.withValues(alpha: 0.9 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
  }

  // ---- ambience ----------------------------------------------------------

  /// Fire along the four edges. Four linear gradients rather than one
  /// vignette: a vignette centres the light, and this needs to read as
  /// flame coming in from the borders.
  void _paintEdgeFire(Canvas canvas, Size size) {
    final intensity = (0.35 + 0.65 * progress).clamp(0.0, 1.0);

    void edge(Rect rect, Offset from, Offset to, double strength) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            from,
            to,
            [
              AppColors.flame.withValues(alpha: 0.55 * strength * intensity),
              AppColors.crimson.withValues(alpha: 0.28 * strength * intensity),
              Colors.transparent,
            ],
            const [0.0, 0.45, 1.0],
          ),
      );
    }

    final vBand = size.height * 0.28;
    final hBand = size.width * 0.22;

    // Bottom burns strongest — fire rises.
    edge(Rect.fromLTWH(0, size.height - vBand, size.width, vBand),
        Offset(0, size.height), Offset(0, size.height - vBand), 1.0);
    edge(Rect.fromLTWH(0, 0, size.width, vBand * 0.7),
        Offset.zero, Offset(0, vBand * 0.7), 0.55);
    edge(Rect.fromLTWH(0, 0, hBand, size.height),
        Offset.zero, Offset(hBand, 0), 0.7);
    edge(Rect.fromLTWH(size.width - hBand, 0, hBand, size.height),
        Offset(size.width, 0), Offset(size.width - hBand, 0), 0.7);
  }

  void _paintEmbers(Canvas canvas, Size size) {
    for (final ember in embers) {
      final t = (progress * ember.speed + ember.phase) % 1.0;

      final x = size.width * (ember.x + sin(t * 2 * pi + ember.phase) * ember.drift);
      final y = size.height * (1.05 - t * ember.rise);

      final envelope = t < 0.12 ? t / 0.12 : (1 - (t - 0.12) / 0.88);
      final flicker = 0.75 + 0.25 * sin(t * 40 + ember.phase * 12);
      final alpha = (envelope * flicker * ember.opacity).clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      // Radial gradient instead of a blurred circle: same falloff, no
      // MaskFilter pass per ember.
      final radius = ember.radius * 3.4;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(x, y),
            radius,
            [
              ember.color.withValues(alpha: alpha * 0.85),
              ember.color.withValues(alpha: alpha * 0.22),
              Colors.transparent,
            ],
            const [0.0, 0.4, 1.0],
          ),
      );
    }
  }

  @override
  bool shouldRepaint(FireSplashPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.burnProgress != burnProgress;
}

class Ember {
  final double x;
  final double radius;
  final double speed;
  final double phase;
  final double drift;
  final double rise;
  final double opacity;
  final Color color;

  const Ember({
    required this.x,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.drift,
    required this.rise,
    required this.opacity,
    required this.color,
  });
}

/// Fixed seed: identical on every launch, built once instead of per frame.
List<Ember> buildEmbers({int count = 18}) {
  final random = Random(7);
  const palette = [AppColors.glow, AppColors.flame, AppColors.scarlet, AppColors.gold];

  return List.generate(count, (index) {
    return Ember(
      x: random.nextDouble(),
      radius: 0.9 + random.nextDouble() * 2.0,
      speed: 0.5 + random.nextDouble() * 0.95,
      phase: random.nextDouble(),
      drift: 0.02 + random.nextDouble() * 0.06,
      rise: 0.75 + random.nextDouble() * 0.5,
      opacity: 0.4 + random.nextDouble() * 0.6,
      color: palette[random.nextInt(palette.length)],
    );
  });
}

/// Radius multipliers around the outline, ~0.72 → ~1.28.
///
/// Smoothed against neighbours and wrapped at both ends: raw values give a
/// spiky star, and an unwrapped list leaves a visible seam where the last
/// point meets the first.
List<double> buildEdgeNoise({int count = 44}) {
  final random = Random(21);
  final raw = List<double>.generate(count, (_) => random.nextDouble());

  return List<double>.generate(count, (i) {
    final prev = raw[(i - 1 + count) % count];
    final next = raw[(i + 1) % count];
    final smoothed = (prev + raw[i] * 2 + next) / 4;
    return 0.72 + smoothed * 0.56;
  });
}