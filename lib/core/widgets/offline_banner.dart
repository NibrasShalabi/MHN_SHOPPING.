import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A slim bar across the top of every screen while the device has no
/// network, so a slow screen never looks like a frozen app.
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _connectivity.checkConnectivity().then(_update);
    _sub = _connectivity.onConnectivityChanged.listen(_update);
  }

  void _update(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (mounted && offline != _offline) setState(() => _offline = offline);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _offline ? const _Bar() : const SizedBox(width: double.infinity),
        ),
        Expanded(
          // The bar already covers the status-bar inset.
          child: _offline ? MediaQuery.removePadding(context: context, removeTop: true, child: widget.child) : widget.child,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.emberDeep,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs + 2),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gold, width: 0.6))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: AppConstants.iconSm, color: AppColors.goldLight),
              const SizedBox(width: AppConstants.spacingSm),
              Text(AppStrings.offline, style: AppTextStyles.caption.copyWith(color: AppColors.goldLight)),
            ],
          ),
        ),
      ),
    );
  }
}
