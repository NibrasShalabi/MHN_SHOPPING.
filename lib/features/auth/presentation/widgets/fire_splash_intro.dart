import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom/app_logo.dart';
import 'fire_splash_painter.dart';

/// Splash intro: an opaque sheet covers the screen and burns away from the
/// middle outward, uncovering the wordmark underneath.
///
/// The logo is a real widget sitting *below* the painter, not something
/// the painter draws — the sheet punches a hole and the logo shows
/// through it. That's why it doesn't fade in: the burn is the reveal.
class FireSplashIntro extends StatefulWidget {
  final VoidCallback onCompleted;

  const FireSplashIntro({super.key, required this.onCompleted});

  @override
  State<FireSplashIntro> createState() => _FireSplashIntroState();
}

class _FireSplashIntroState extends State<FireSplashIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Ember> _embers = buildEmbers();
  late final List<double> _edgeNoise = buildEdgeNoise();

  // Timeline, as fractions of the total duration:
  //   0.00–0.22  fire builds on the edges, embers rise
  //   0.22–0.86  the sheet catches in the middle and burns outward
  //   0.88–1.00  scene dims out into the onboarding slides
  late final Animation<double> _burn = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.22, 0.86, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _sceneFade = Tween<double>(begin: 1, end: 0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.88, 1.0, curve: Curves.easeIn),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.splashIntroDuration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onCompleted();
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sceneFade,
      builder: (context, child) => Opacity(opacity: _sceneFade.value, child: child),
      child: ColoredBox(
        color: AppColors.surface,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Underneath the sheet — revealed as the burn opens up.
            const Center(child: AppLogo(large: true, glow: true)),

            // The sheet, with the hole burnt through it.
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: FireSplashPainter(
                  progress: _controller.value,
                  burnProgress: _burn.value,
                  embers: _embers,
                  edgeNoise: _edgeNoise,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}