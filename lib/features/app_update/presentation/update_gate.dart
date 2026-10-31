import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/shared_prefs_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom/custom_button.dart';
import '../../../core/widgets/gold_frame.dart';
import '../data/app_update_repository.dart';

/// Wraps the whole app (MaterialApp.builder). On launch it compares the
/// installed build with config/app:
/// - below minBuild → a full screen that can't be dismissed;
/// - below latestBuild → a card at the bottom; "لاحقاً" hides it until the
///   next release.
/// Web is skipped: a reload already serves the newest build.
class UpdateGate extends StatefulWidget {
  final Widget child;

  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  final _repository = AppUpdateRepository(FirebaseFirestore.instance);
  AppUpdateInfo? _info;
  UpdateNeed _need = UpdateNeed.none;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _check();
  }

  Future<void> _check() async {
    final info = await _repository.fetch();
    if (info == null) return;
    final need = info.needFor(await _repository.installedBuild());
    final dismissed = need == UpdateNeed.optional && SharedPrefsService.dismissedUpdateBuild == info.latestBuild;
    if (!mounted || need == UpdateNeed.none || dismissed) return;
    setState(() {
      _info = info;
      _need = need;
    });
  }

  void _later() {
    SharedPrefsService.setDismissedUpdateBuild(_info!.latestBuild);
    setState(() => _need = UpdateNeed.none);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Stack(
      children: [
        widget.child,
        if (info != null && _need == UpdateNeed.required)
          Positioned.fill(child: _UpdateCard(info: info, fullScreen: true)),
        if (info != null && _need == UpdateNeed.optional)
          Positioned(
            left: AppConstants.spacingMd,
            right: AppConstants.spacingMd,
            bottom: AppConstants.spacingMd,
            child: _UpdateCard(info: info, onLater: _later),
          ),
      ],
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final AppUpdateInfo info;
  final bool fullScreen;
  final VoidCallback? onLater;

  const _UpdateCard({required this.info, this.fullScreen = false, this.onLater});

  Future<void> _open() async {
    final uri = Uri.tryParse(info.storeUrl);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final card = GoldFrame(
      radius: AppConstants.radiusLg,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.system_update_outlined, color: AppColors.gold, size: 36),
            const SizedBox(height: AppConstants.spacingSm),
            GoldText(
              fullScreen ? AppStrings.updateRequiredTitle : AppStrings.updateAvailableTitle,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            if (info.latestName.isNotEmpty)
              Text(AppStrings.updateVersion(info.latestName), style: AppTextStyles.caption, textAlign: TextAlign.center),
            if (info.notes.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(info.notes, style: AppTextStyles.body, textAlign: TextAlign.center),
            ],
            const SizedBox(height: AppConstants.spacingMd),
            CustomButton(label: AppStrings.updateNow, icon: Icons.download_outlined, onPressed: _open),
            if (onLater != null)
              TextButton(onPressed: onLater, child: Text(AppStrings.updateLater, style: AppTextStyles.caption)),
          ],
        ),
      ),
    );
    if (!fullScreen) return Material(type: MaterialType.transparency, child: card);
    // Blocks every tap underneath — the old build can't be used.
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(padding: const EdgeInsets.all(AppConstants.spacingLg), child: card),
          ),
        ),
      ),
    );
  }
}
