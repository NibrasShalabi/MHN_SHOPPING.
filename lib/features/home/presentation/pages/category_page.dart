import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/seen_products_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../domain/entities/product.dart';
import '../cubits/category_cubit.dart';
import '../cubits/category_state.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/products_grid.dart';

class CategoryPage extends StatefulWidget {
  final SeenProductsStore seenProductsStore;

  const CategoryPage({super.key, required this.seenProductsStore});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ScrollController _scrollController = ScrollController();

  /// Snapshot of what was already seen when the page opened, so badges
  /// don't vanish under the user's eyes mid-scroll — they disappear on the
  /// next visit, which is what "show it the first time" means.
  final Set<String> _seenOnEntry = {};

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

  /// Fires one screen ahead of the bottom so the next batch is usually
  /// ready before the user gets there. The cubit guards against duplicate
  /// requests, so a burst of scroll events is harmless.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - AppConstants.loadMoreThreshold) {
      context.read<CategoryCubit>().loadMore();
    }
  }

  bool _shouldShowNewBadge(Product product) {
    if (!product.isNew) return false;
    if (_seenOnEntry.contains(product.id)) return false;
    return !widget.seenProductsStore.hasSeen(product.id);
  }

  void _markVisibleAsSeen(List<Product> products) {
    for (final product in products.where((p) => p.isNew)) {
      if (!widget.seenProductsStore.hasSeen(product.id)) {
        _seenOnEntry.add(product.id);
        widget.seenProductsStore.markSeen(product.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        bottom: const AppBarBottomBorder(),
        centerTitle: true,
        title: BlocBuilder<CategoryCubit, CategoryState>(
          buildWhen: (previous, current) => previous.category != current.category,
          builder: (context, state) => Text(
            state.category?.name ?? '',
            style: AppTextStyles.heading2,
          ),
        ),
      ),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state.status == CategoryStatus.success) {
            _markVisibleAsSeen(state.products);
          }
          if (state.failure != null && state.status != CategoryStatus.failure) {
            AppSnackbar.error(context, state.failure!.message);
          }
        },
        builder: (context, state) {
          if (state.status == CategoryStatus.loading || state.status == CategoryStatus.initial) {
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spacingSm),
              FilterChipsRow(
                filters: state.category?.filters ?? const [],
                selectedFilterId: state.selectedFilterId,
                onFilterSelected: (filterId) =>
                    context.read<CategoryCubit>().selectFilter(filterId),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Expanded(
                child: state.isFiltering
                    ? const CustomLoadingIndicator()
                    : RefreshIndicator(
                  onRefresh: () => context.read<CategoryCubit>().load(forceRefresh: true),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (state.products.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              AppStrings.noResultsFound,
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else ...[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingMd,
                          ),
                          sliver: ProductsSliverGrid(
                            products: state.products,
                            shouldShowNewBadge: _shouldShowNewBadge,
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
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}