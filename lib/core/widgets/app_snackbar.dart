import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_durations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SnackType { info, success, error }

/// The app's single notification surface.
///
/// Deliberately NOT ScaffoldMessenger/SnackBar: that widget is anchored to
/// the bottom, where it sits on top of the nav bar and the pinned action
/// bars (add-to-cart, checkout) — exactly the controls the user just
/// touched. This one drops in from the top instead, on the app's own
/// surfaces, and never covers a primary action.
///
/// Call it from anywhere: AppSnackbar.success(context, AppStrings.x)
class AppSnackbar {
  AppSnackbar._();

  /// Keyed by overlay, not global: a single static entry leaked across
  /// route changes — a snackbar shown on one screen could be removed from
  /// an overlay it no longer belongs to.
  static final Map<OverlayState, OverlayEntry> _active = {};

  static void info(BuildContext context, String message) =>
      _show(context, message, SnackType.info);

  static void success(BuildContext context, String message) =>
      _show(context, message, SnackType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, SnackType.error);

  static void _show(BuildContext context, String message, SnackType type) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    // Replace whatever is on this overlay — stacked toasts read as noise.
    _active.remove(overlay)?.remove();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _SnackbarView(
        message: message,
        type: type,
        onDismissed: () {
          if (_active[overlay] == entry) {
            _active.remove(overlay);
            entry.remove();
          }
        },
      ),
    );

    _active[overlay] = entry;
    overlay.insert(entry);
  }
}

class _SnackbarView extends StatefulWidget {
  final String message;
  final SnackType type;
  final VoidCallback onDismissed;

  const _SnackbarView({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_SnackbarView> createState() => _SnackbarViewState();
}

class _SnackbarViewState extends State<_SnackbarView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.normal);
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    _scheduleDismiss();
  }

  Future<void> _scheduleDismiss() async {
    await Future.delayed(AppConstants.snackbarDuration);
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _accent => switch (widget.type) {
    SnackType.info => AppColors.gold,
    SnackType.success => AppColors.success,
    SnackType.error => AppColors.error,
  };

  IconData get _icon => switch (widget.type) {
    SnackType.info => Icons.info_outline,
    SnackType.success => Icons.check_circle_outline,
    SnackType.error => Icons.error_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppConstants.spacingSm,
      left: AppConstants.spacingMd,
      right: AppConstants.spacingMd,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: const ValueKey('app-snackbar'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismissed(),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: _accent, width: AppConstants.borderThin),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: AppConstants.elevationLg,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(_icon, color: _accent, size: AppConstants.iconMd),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
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