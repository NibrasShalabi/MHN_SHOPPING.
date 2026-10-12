import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/entry_banner.dart';

/// Entry to the suppliers section: the storefront art fading into the fire.
class SuppliersEntryBanner extends StatelessWidget {
  final VoidCallback onTap;

  const SuppliersEntryBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return EntryBanner(
      onTap: onTap,
      artWidth: 170,
      fadeArt: true,
      art: Image.asset('assets/images/suppliers.jpg', fit: BoxFit.cover, height: EntryBanner.height, filterQuality: FilterQuality.medium),
      tagIcon: Icons.verified_outlined,
      tag: AppStrings.suppliersBannerTag,
      title: AppStrings.suppliersBannerTitle,
      body: AppStrings.suppliersBannerBody,
      button: AppStrings.browseSuppliers,
    );
  }
}
