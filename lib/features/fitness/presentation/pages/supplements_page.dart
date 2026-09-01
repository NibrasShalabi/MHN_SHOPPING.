import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../home/presentation/widgets/categories_grid.dart';
import '../cubits/catalog_categories_cubit.dart';
import '../cubits/catalog_categories_state.dart';
import '../widgets/medical_notice_card.dart';

/// Fitness shelves — the same category grid the store uses.
///
/// Tapping through lands on the standard category page (filters, paging,
/// product details), because these are ordinary catalog categories that
/// happen to hold unpriced items. Adding an "energy drinks" shelf later is
/// a data entry, not another screen.
class SupplementsPage extends StatefulWidget {
  const SupplementsPage({super.key});

  @override
  State<SupplementsPage> createState() => _SupplementsPageState();
}

class _SupplementsPageState extends State<SupplementsPage> {
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
        title: Text(AppStrings.supplements, style: AppTextStyles.heading2),
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
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              children: [
                const MedicalNoticeCard(
                  message: AppStrings.supplementsNotice,
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: AppConstants.spacingXl),
                CategoriesGrid(
                  categories: state.categories,
                  onCategoryTap: (category) =>
                      context.push(RouteNames.categoryPath(category.id)),
                ),
                const SizedBox(height: AppConstants.spacingLg),
              ],
            ),
          );
        },
      ),
    );
  }
}