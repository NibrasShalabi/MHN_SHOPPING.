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
import '../../../orders/presentation/widgets/loyalty_explainer_card.dart';
import '../cubits/category_cubit.dart';
import '../cubits/category_state.dart';
import '../widgets/products_grid.dart';

/// Loyalty store — the same product grid as the rest of the shop, priced
/// in points.
///
/// Runs on CategoryCubit like any other category, so paging and caching
/// come for free and a change to the product card shows up here too. The
/// only addition is the balance header, since the price means nothing
/// without knowing what you have.
class LoyaltyStorePage extends StatefulWidget {
  const LoyaltyStorePage({super.key});

  @override
  State<LoyaltyStorePage> createState() => _LoyaltyStorePageState();
}

class _LoyaltyStorePageState extends State<LoyaltyStorePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CategoryCubit>().load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - AppConstants.loadMoreThreshold) {
      context.read<CategoryCubit>().loadMore();
    }
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
        title: Text(AppStrings.loyaltyStore, style: AppTextStyles.heading2),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state.status == CategoryStatus.loading ||
              state.status == CategoryStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.status == CategoryStatus.failure) {
            return Center(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CategoryCubit>().load(forceRefresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.spacingMd),
                    child: LoyaltyExplainerCard(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
                  sliver: ProductsSliverGrid(
                    products: state.products,
                    // Loyalty gifts don't carry the "new" treatment — the
                    // badge is a merchandising cue for the shop.
                    shouldShowNewBadge: (_) => false,
                    onProductTap: (product) =>
                        context.push(RouteNames.productPath(product.id)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: state.isLoadingMore
                        ? const CustomLoadingIndicator()
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}