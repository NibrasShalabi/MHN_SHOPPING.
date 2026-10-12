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
import '../widgets/supplier_card.dart';
import '../cubits/suppliers_cubit.dart';
import '../cubits/suppliers_state.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/content_width.dart';

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
      body: ContentWidth(
        child: BlocBuilder<SuppliersCubit, SuppliersState>(
        builder: (context, state) {
          if (state.status == SuppliersStatus.loading ||
              state.status == SuppliersStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.status == SuppliersStatus.failure) {
            return ErrorRetry(failure: state.failure, onRetry: () => context.read<SuppliersCubit>().load(forceRefresh: true));
          }

          // Pull-to-refresh works on the empty state too — a new supplier
          // is one swipe away.
          return RefreshIndicator(
            onRefresh: () => context.read<SuppliersCubit>().load(forceRefresh: true),
            child: state.suppliers.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: AppConstants.spacingXl * 3),
                      Center(child: Text(AppStrings.noResultsFound, style: AppTextStyles.body)),
                    ],
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    // One per row on phones, two on tablets, three on desktop.
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
                      mainAxisExtent: SupplierCard.height,
                      crossAxisSpacing: AppConstants.spacingMd,
                      mainAxisSpacing: AppConstants.spacingMd,
                    ),
                    itemCount: state.suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = state.suppliers[index];
                      return SupplierCard(
                        supplier: supplier,
                        onTap: () => context.push(RouteNames.supplierPath(supplier.id)),
                      );
                    },
                  ),
          );
        },
      ),
      ),
    );
  }
}
