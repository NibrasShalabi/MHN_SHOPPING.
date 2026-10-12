import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../router/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_bar_bottom_border.dart';
import 'custom/app_logo.dart';
import 'gold_frame.dart';

/// The site footer on wide screens: brand, the main links, help, and the
/// copyright line.
class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  static const _links = [
    (RouteNames.about, AppStrings.aboutUs),
    (RouteNames.suppliers, AppStrings.suppliers),
    (RouteNames.deals, AppStrings.dealsTitle),
    (RouteNames.currency, AppStrings.currencyConverter),
  ];

  static const _help = [
    (RouteNames.support, AppStrings.contactUs),
    (RouteNames.orderTracking, AppStrings.orderTracking),
    (RouteNames.suggestProduct, AppStrings.suggestProduct),
    (RouteNames.rateApp, AppStrings.rateApp),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppBarBottomBorder(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogo(),
                    const SizedBox(height: AppConstants.spacingMd),
                    Text(
                      AppStrings.footerAbout,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.8),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingXl),
              Expanded(child: _LinkColumn(title: AppStrings.footerLinks, links: _links)),
              Expanded(child: _LinkColumn(title: AppStrings.footerHelp, links: _help)),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
          child: Text(
            AppStrings.footerRights(DateTime.now().year),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
          ),
        ),
      ],
    );
  }
}

class _LinkColumn extends StatelessWidget {
  final String title;
  final List<(String, String)> links;

  const _LinkColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldText(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppConstants.spacingSm),
        for (final (path, label) in links)
          InkWell(
            onTap: () => path == RouteNames.orderTracking ? context.go(path) : context.push(path),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs + 2),
              child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
            ),
          ),
      ],
    );
  }
}
