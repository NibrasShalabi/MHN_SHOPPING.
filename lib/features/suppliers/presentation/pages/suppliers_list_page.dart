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
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/supplier.dart';
import '../cubits/suppliers_cubit.dart';
import '../cubits/suppliers_state.dart';

class SuppliersListPage extends StatefulWidget {
  const SuppliersListPage({super.key});

  @override
  State<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends State<SuppliersListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SuppliersCubit>().load();
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
        title: Text(AppStrings.suppliers, style: AppTextStyles.heading2),
      ),
      body: BlocBuilder<SuppliersCubit, SuppliersState>(
        builder: (context, state) {
          if (state.status == SuppliersStatus.loading ||
              state.status == SuppliersStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.status == SuppliersStatus.failure) {
            return Center(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body,
              ),
            );
          }

          if (state.suppliers.isEmpty) {
            return Center(
              child: Text(AppStrings.noResultsFound, style: AppTextStyles.body),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<SuppliersCubit>().load(forceRefresh: true),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: state.suppliers.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSm),
              itemBuilder: (context, index) {
                final supplier = state.suppliers[index];
                return _SupplierTile(
                  supplier: supplier,
                  onTap: () => context.push(RouteNames.supplierPath(supplier.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SupplierTile extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;

  const _SupplierTile({required this.supplier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: AppConstants.iconLg + AppConstants.spacingMd,
            height: AppConstants.iconLg + AppConstants.spacingMd,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            // TODO(logic-phase): swap for CachedNetworkImage(supplier.logoUrl).
            child: const Icon(
              Icons.storefront_outlined,
              color: AppColors.iconPrimary,
              size: AppConstants.iconMd,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  supplier.description,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_left,
            color: AppColors.textDisabled,
            size: AppConstants.iconMd,
          ),
        ],
      ),
    );
  }
}