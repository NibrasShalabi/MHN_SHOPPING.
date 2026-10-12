import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_durations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gold_frame.dart';

enum SnackType { info, success, error }

/// The app's single notification surface.
///
/// Deliberately NOT ScaffoldMessenger/SnackBar: that widget is anchored to
/// the bottom, where it sits on top of the nav bar and the pinned action
/// bars (add-to-cart, checkout) — exactly the controls the user just
/// touched. This one drops in from the top instead, in the app's gold and
/// fire frame, and never covers a primary action.
///
/// Call it from anywhere: AppSnackbar.success(context, AppStrings.x), or
/// AppSnackbar.confirm(context) for a wordless "done" (added to cart).
class AppSnackbar {
  AppSnackbar._();

  /// Keyed by overlay, not global: a single static entry leaked across
  /// route changes — a snackbar shown on one screen could be removed from
  /// an overlay it no longer belongs to.
  static final Map<OverlayState, OverlayEntry> _active = {};

  static void info(BuildContext context, String message) =>
      _show(context, (done) => _SnackbarView(message: message, type: SnackType.info, onDismissed: done));

  static void success(BuildContext context, String message) =>
      _show(context, (done) => _SnackbarView(message: message, type: SnackType.success, onDismissed: done));

  static void error(BuildContext context, String message) =>
      _show(context, (done) => _SnackbarView(message: message, type: SnackType.error, onDismissed: done));

  /// A small gold-and-coal medallion that drops in with a check being drawn.
  static void confirm(BuildContext context) => _show(context, (done) => _ConfirmView(onDismissed: done));

  static void _show(BuildContext context, Widget Function(VoidCallback done) build) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    // Replace whatever is on this overlay — stacked toasts read as noise.
    _active.remove(overlay)?.remove();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => build(() {
        if (_active[overlay] == entry) {
          _active.remove(overlay);
          entry.remove();
        }
      }),
    );

    _active[overlay] = entry;
    overlay.insert(entry);
  }
}

class _SnackbarView extends StatefulWidget {
  final String message;
  final SnackType type;
  final VoidCallback onDismissed;

  const _SnackbarView({required this.message, required this.type, required this.onDismissed});

  @override
  State<_SnackbarView> createState() => _SnackbarViewState();
}

class _SnackbarViewState extends State<_SnackbarView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: AppDurations.normal);
  late final Animation<Offset> _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _scheduleDismiss();
  }

  Future<void> _scheduleDismiss() async {
    await Future.delayed(AppConstants.snackbarDuration);
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData get _icon => switch (widget.type) {
        SnackType.info => Icons.info_outline_rounded,
        SnackType.success => Icons.check_rounded,
        SnackType.error => Icons.priority_high_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final isError = widget.type == SnackType.error;
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppConstants.spacingSm,
      left: AppConstants.spacingMd,
      right: AppConstants.spacingMd,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Dismissible(
            key: const ValueKey('app-snackbar'),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onDismissed(),
            child: GoldFrame(
              radius: AppConstants.radiusMd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd, vertical: AppConstants.spacingSm + 2),
                child: Row(
                  children: [
                    _Medallion(size: 30, error: isError, child: Icon(_icon, size: 18, color: isError ? Colors.white : AppColors.surfaceDark)),
                    const SizedBox(width: AppConstants.spacingSm + 2),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTextStyles.body.copyWith(color: AppColors.goldLight, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A gold coin for success/info, a scarlet one with a gold rim for errors.
class _Medallion extends StatelessWidget {
  final double size;
  final bool error;
  final Widget child;

  const _Medallion({required this.size, required this.child, this.error = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: error ? null : AppColors.goldGradient,
        color: error ? AppColors.scarlet : null,
        border: Border.all(color: AppColors.goldLight, width: 1),
        boxShadow: [BoxShadow(color: (error ? AppColors.scarlet : AppColors.gold).withValues(alpha: 0.45), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

/// Drops in under the status bar, a gold check is drawn inside a coal disc
/// with a gold ring, then it lifts away — about a second in all.
class _ConfirmView extends StatefulWidget {
  final VoidCallback onDismissed;

  const _ConfirmView({required this.onDismissed});

  @override
  State<_ConfirmView> createState() => _ConfirmViewState();
}

class _ConfirmViewState extends State<_ConfirmView> with SingleTickerProviderStateMixin {
  static const double _size = 64;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));

  // 0–30%: drop with a bounce · 20–55%: check drawn · 80–100%: lift and fade.
  late final Animation<double> _drop =
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3, curve: Curves.easeOutBack));
  late final Animation<double> _check =
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.55, curve: Curves.easeOut));
  late final Animation<double> _leave =
      CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1, curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + AppConstants.spacingLg;
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final y = (1 - _drop.value) * -(_size + top) - _leave.value * 24;
            return Opacity(
              opacity: (1 - _leave.value).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, y),
                child: Center(
                  child: Container(
                    width: _size,
                    height: _size,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                      boxShadow: [
                        BoxShadow(color: AppColors.gold.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 1),
                        const BoxShadow(color: Color(0x88000000), blurRadius: 12, offset: Offset(0, 6)),
                      ],
                    ),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [AppColors.emberDeep, AppColors.surfaceDark]),
                      ),
                      child: CustomPaint(painter: _CheckPainter(_check.value)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A check mark drawn up to [progress] (0–1), in the gold gradient.
class _CheckPainter extends CustomPainter {
  final double progress;

  const _CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.28, h * 0.52)
      ..lineTo(w * 0.44, h * 0.67)
      ..lineTo(w * 0.73, h * 0.36);
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    final paint = Paint()
      ..shader = AppColors.goldGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(3, w * 0.08)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
