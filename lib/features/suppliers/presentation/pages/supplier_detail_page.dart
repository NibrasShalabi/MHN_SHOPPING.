import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m_h_nshopping/features/fitness/presentation/cubits/catalog_categories_cubit.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../fitness/presentation/cubits/catalog_categories_state.dart';
import '../../../../core/utils/whatsapp.dart';
import '../../domain/entities/supplier.dart';
import '../../../home/presentation/widgets/categories_grid.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/content_width.dart';
import '../../../../core/widgets/gold_frame.dart';
import '../widgets/supplier_visuals.dart';

/// One supplier's storefront: their own categories, browsed with the same
/// grid and filters as the main store — a supplier is a different entry
/// point into the catalog, not a different catalog.
class SupplierDetailPage extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailPage({super.key, required this.supplier});

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CatalogCategoriesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        centerTitle: true,
        bottom: const AppBarBottomBorder(),
        title: Text(widget.supplier.name, style: AppTextStyles.heading2),
      ),
      body: ContentWidth(
        child: BlocBuilder<CatalogCategoriesCubit, CatalogCategoriesState>(
        builder: (context, state) {
          if (state.status == CatalogCategoriesStatus.loading ||
              state.status == CatalogCategoriesStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.status == CatalogCategoriesStatus.failure) {
            return ErrorRetry(failure: state.failure, onRetry: () => context.read<CatalogCategoriesCubit>().load(forceRefresh: true));
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<CatalogCategoriesCubit>().load(forceRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SupplierHeader(supplier: widget.supplier),
                  const SizedBox(height: AppConstants.spacingXl),
                  if (state.categories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingLg),
                      child: Center(
                        child: Text(AppStrings.noResultsFound, style: AppTextStyles.body),
                      ),
                    )
                  else
                    CategoriesGrid(
                      categories: state.categories,
                      onCategoryTap: (category) =>
                          context.push(RouteNames.categoryPath(category.id)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}

/// The storefront at the top of the page: a wide cover, the logo medallion
/// on its edge, the calligraphic name, then where to find them.
class _SupplierHeader extends StatelessWidget {
  static const double _logo = 96;

  final Supplier supplier;

  const _SupplierHeader({required this.supplier});

  @override
  Widget build(BuildContext context) {
    final cover = AppConstants.isWideScreen(context) ? 260.0 : 190.0;
    return GoldFrame(
      fill: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.surfaceDark, AppColors.surfaceDark, AppColors.emberDeep],
        stops: [0.0, 0.55, 1.0],
      ),
      child: Stack(
        children: [
          SupplierCover(supplier: supplier, height: cover),
          Padding(
            padding: EdgeInsets.only(top: cover - _logo / 2, bottom: AppConstants.spacingLg),
            // Full width so everything centres; a Stack child otherwise
            // shrinks to its content and sits in the corner on wide screens.
            child: SizedBox(
              width: double.infinity,
              child: Column(
              children: [
                SupplierMonogram(supplier: supplier, size: _logo),
                const SizedBox(height: AppConstants.spacingSm),
                const SupplierChip(icon: Icons.verified_outlined, label: AppStrings.suppliersBannerTag),
                const SizedBox(height: AppConstants.spacingXs),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
                  child: GoldText(
                    supplier.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1.copyWith(
                      fontFamily: 'ArefRuqaa',
                      fontWeight: FontWeight.bold,
                      fontSize: (AppTextStyles.heading1.fontSize ?? 24) + 8,
                      height: 1.3,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                  ),
                ),
                if (supplier.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXl, vertical: AppConstants.spacingXs),
                    child: Text(
                      supplier.description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.85), height: 1.7),
                    ),
                  ),
                if (supplier.address.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  SupplierChip(icon: Icons.place_outlined, label: supplier.address),
                ],
                const SizedBox(height: AppConstants.spacingMd),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
                    child: Row(
                      children: [
                        if (supplier.phone.isNotEmpty)
                          Expanded(
                            child: _HeaderAction(
                              icon: Icons.chat_outlined,
                              label: AppStrings.supplierWhatsapp,
                              filled: true,
                              onTap: () => WhatsApp.open(context, supplier.phone),
                            ),
                          ),
                        if (supplier.phone.isNotEmpty && supplier.mapsUrl.isNotEmpty)
                          const SizedBox(width: AppConstants.spacingSm),
                        if (supplier.mapsUrl.isNotEmpty)
                          Expanded(
                            child: _HeaderAction(
                              icon: Icons.map_outlined,
                              label: AppStrings.supplierMap,
                              onTap: () => WhatsApp.openLink(context, supplier.mapsUrl),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gold-filled for the main action, gold-outlined for the secondary one.
class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeaderAction({required this.icon, required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.radiusMd);
    final fg = filled ? AppColors.surfaceDark : AppColors.goldLight;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm + 2),
          decoration: BoxDecoration(
            gradient: filled ? AppColors.goldGradient : null,
            borderRadius: radius,
            border: filled ? null : Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppConstants.iconSm + 2, color: fg),
              const SizedBox(width: AppConstants.spacingSm),
              Text(label, style: AppTextStyles.body.copyWith(color: fg, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
