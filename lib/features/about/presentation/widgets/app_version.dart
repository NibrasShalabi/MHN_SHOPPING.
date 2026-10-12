import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "الإصدار 1.0.0 (1)" — what support asks for first.
class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  static final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snap) => Text(
        snap.data == null ? '' : AppStrings.appVersion(snap.data!.version, snap.data!.buildNumber),
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
      ),
    );
  }
}
