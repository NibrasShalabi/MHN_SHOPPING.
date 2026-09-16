import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/custom/custom_search_bar.dart';
import '../../../../core/widgets/custom/app_logo.dart';
import '../../../../core/widgets/custom/loyalty_points_badge.dart';
import '../../../deals/presentation/widgets/fire_deals_banner.dart';
import '../../domain/entities/category.dart';
import '../cubits/home_cubit.dart';
import '../cubits/home_state.dart';
import '../widgets/categories_grid.dart';
import '../widgets/fitness_entry_banner.dart';
import '../widgets/promo_swiper.dart';

class HomePage extends StatefulWidget {
  final bool showFitnessSection;
  const HomePage({super.key, required this.showFitnessSection});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _categorySearchController = TextEditingController();
  String _categoryQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  @override
  void dispose() {
    _categorySearchController.dispose();
    super.dispose();
  }

  List<Category> _filteredCategories(List<Category> categories) {
    if (_categoryQuery.isEmpty) return categories;
    final query = _categoryQuery.trim().toLowerCase();
    return categories.where((c) => c.name.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      endDrawer: const AppDrawer(),
      appBar: AppConstants.isWideScreen(context)
          ? null
          : AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        bottom: const AppBarBottomBorder(),
        toolbarHeight: AppConstants.appBarHeight,
        automaticallyImplyLeading: false,
        titleSpacing: AppConstants.spacingMd,
        title: const Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppLogo(),
        ),
        actions: [
          const LoyaltyPointsBadge(points: 0),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.iconPrimary),
              tooltip: AppStrings.menu,
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: AppConstants.spacingXs),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading || state.status == HomeStatus.initial) {
            return const CustomLoadingIndicator();
          }
          if (state.status == HomeStatus.failure) {
            return Center(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PromoSwiper(banners: state.banners),
                  const SizedBox(height: AppConstants.spacingXl),
                  if (widget.showFitnessSection) ...[
                    FitnessEntryBanner(
                      onTap: () => context.push(RouteNames.fitnessHome),
                    ),
                    const SizedBox(height: AppConstants.spacingXl),
                  ],

                  // NEW: بنر شرار ونار — يظهر بس إذا في عروض
                  if (state.promotions.isNotEmpty) ...[
                    FireDealsBanner(
                      onTap: () => context.push(RouteNames.deals),
                    ),
                    const SizedBox(height: AppConstants.spacingXl),
                  ],

                  Text(AppStrings.categories, style: AppTextStyles.heading2),
                  const SizedBox(height: AppConstants.spacingMd),
                  CustomSearchBar(
                    controller: _categorySearchController,
                    hint: AppStrings.searchCategoriesHint,
                    onChanged: (value) => setState(() => _categoryQuery = value),
                    onClear: () {
                      _categorySearchController.clear();
                      setState(() => _categoryQuery = '');
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  if (_categoryQuery.isNotEmpty && _filteredCategories(state.categories).isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingLg),
                      child: Center(
                        child: Text(AppStrings.noResultsFound, style: AppTextStyles.body),
                      ),
                    )
                  else
                    CategoriesGrid(
                      categories: _filteredCategories(state.categories),
                      onCategoryTap: (category) =>
                          context.push(RouteNames.categoryPath(category.id)),
                    ),
                  const SizedBox(height: AppConstants.spacingLg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}