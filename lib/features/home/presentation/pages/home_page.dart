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
import '../../../../core/widgets/custom/app_logo.dart';
import '../../../../core/widgets/custom/loyalty_points_badge.dart';
import '../cubits/home_cubit.dart';
import '../cubits/home_state.dart';
import '../widgets/categories_grid.dart';
import '../widgets/fitness_entry_banner.dart';
import '../widgets/promo_swiper.dart';

class HomePage extends StatefulWidget {
  /// Whether to show the fitness entry point.
  ///
  /// Passed in rather than checked here: the router already owns the
  /// gender gate, and having two places decide it is how they end up
  /// disagreeing.
  final bool showFitnessSection;

  const HomePage({super.key, required this.showFitnessSection});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // endDrawer, not drawer: in RTL a plain `drawer` slides in from the
      // right, and the button that opens it is now on the left — the
      // panel has to come from the same side the user tapped.
      //
      // Declared on this Scaffold rather than the shell's: Scaffold.of()
      // below resolves to the nearest one, so a drawer on an outer
      // Scaffold would never be found by this app bar's button.
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        bottom: const AppBarBottomBorder(),
        toolbarHeight: AppConstants.appBarHeight,
        // RTL: `leading` is the right-hand slot, so the wordmark sits
        // there and the menu goes to `actions` on the left. The loyalty
        // balance rides next to the menu button rather than the name —
        // both are things you act on, the name isn't.
        automaticallyImplyLeading: false,
        titleSpacing: AppConstants.spacingMd,
        title: const Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppLogo(),
        ),
        actions: [
          // TODO(logic-phase): read the real balance from LoyaltyCubit.
          const LoyaltyPointsBadge(points: 0),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.goldLight),
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
                  Text(AppStrings.categories, style: AppTextStyles.heading2),
                  const SizedBox(height: AppConstants.spacingMd),
                  CategoriesGrid(
                    categories: state.categories,
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