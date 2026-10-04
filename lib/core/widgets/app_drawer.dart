import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'custom/app_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const List<_MenuEntry> _entries = [
    _MenuEntry(path: RouteNames.about, icon: Icons.info_outline, label: AppStrings.aboutUs),
    _MenuEntry(path: RouteNames.suppliers, icon: Icons.storefront_outlined, label: AppStrings.suppliers),
    _MenuEntry(path: RouteNames.currency, icon: Icons.currency_exchange, label: AppStrings.currencyConverter),
    _MenuEntry(path: RouteNames.support, icon: Icons.headset_mic_outlined, label: AppStrings.support),
    _MenuEntry(path: RouteNames.rateApp, icon: Icons.thumb_up_outlined, label: AppStrings.rateApp),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              decoration: const BoxDecoration(gradient: AppColors.emberDarkGradient),
              child: const Align(alignment: AlignmentDirectional.centerStart, child: AppLogo()),
            ),
            const SizedBox(height: AppConstants.appBarBorderHeight),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
                children: _entries
                    .map((entry) => _MenuTile(
                  entry: entry,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push(entry.path);
                  },
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuEntry {
  final String path;
  final IconData icon;
  final String label;
  const _MenuEntry({required this.path, required this.icon, required this.label});
}

class _MenuTile extends StatelessWidget {
  final _MenuEntry entry;
  final VoidCallback onTap;
  const _MenuTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          child: Row(
            children: [
              Icon(entry.icon, size: AppConstants.iconMd, color: AppColors.iconPrimary),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(child: Text(entry.label, style: AppTextStyles.body)),
              const Icon(Icons.chevron_left, size: AppConstants.iconSm, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}