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
import '../../domain/entities/supplier.dart';
import '../../../home/presentation/widgets/categories_grid.dart';

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
            return Center(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body,
              ),
            );
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppConstants.iconLg + AppConstants.spacingLg,
          height: AppConstants.iconLg + AppConstants.spacingLg,
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            shape: BoxShape.circle,
          ),
          // TODO(logic-phase): swap for CachedNetworkImage(supplier.logoUrl).
          child: const Icon(
            Icons.storefront_outlined,
            color: AppColors.iconPrimary,
            size: AppConstants.iconLg,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplier.name,
                style: AppTextStyles.heading2.copyWith(color: AppColors.gold),
              ),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                supplier.description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}