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
      body: BlocBuilder<CatalogCategoriesCubit, CatalogCategoriesState>(
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
    );
  }
}

class _SupplierHeader extends StatelessWidget {
  final Supplier supplier;

  const _SupplierHeader({required this.supplier});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppConstants.radiusLg);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.surfaceWine, AppColors.surfaceElevated],
        ),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: AppConstants.borderThin),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            supplier.name,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.gold,
              fontFamily: 'ArefRuqaa',
              fontSize: (AppTextStyles.heading2.fontSize ?? 18) + 8,
              height: 1.2,
            ),
          ),
          if (supplier.description.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Text(supplier.description, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.7)),
          ],
          const SizedBox(height: AppConstants.spacingMd),
          Container(height: 1, decoration: const BoxDecoration(gradient: AppColors.goldGradient)),
          const SizedBox(height: AppConstants.spacingMd),
          if (supplier.address.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, size: AppConstants.iconSm + 2, color: AppColors.goldLight),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(child: Text(supplier.address, style: AppTextStyles.caption.copyWith(height: 1.6))),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
          ],
          Row(
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
              if (supplier.phone.isNotEmpty && supplier.mapsUrl.isNotEmpty) const SizedBox(width: AppConstants.spacingSm),
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
    final fg = filled ? AppColors.surface : AppColors.gold;
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
