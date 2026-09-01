import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../cubits/orders_cubit.dart';
import '../cubits/orders_state.dart';
import '../widgets/admin_message_tile.dart';
import '../widgets/loyalty_explainer_card.dart';
import '../widgets/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().load();
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
        title: Text(AppStrings.orderTracking, style: AppTextStyles.heading2),
      ),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listener: (context, state) {
          if (state.failure != null && state.status != OrdersStatus.failure) {
            AppSnackbar.error(context, state.failure!.message);
          }
        },
        builder: (context, state) {
          if (state.status == OrdersStatus.loading || state.status == OrdersStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.status == OrdersStatus.failure) {
            return Center(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<OrdersCubit>().load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              children: [
                if (state.messages.isNotEmpty) ...[
                  _SectionTitle(
                    title: AppStrings.adminMessages,
                    badgeCount: state.messageCount,
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    AppStrings.tapToDismiss,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  ...state.messages.map(
                        (message) => AdminMessageTile(
                      key: ValueKey(message.id),
                      message: message,
                      onDismiss: () =>
                          context.read<OrdersCubit>().dismissMessage(message.id),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXl),
                ],

                if (state.orders.isEmpty)
                  const _EmptyOrders()
                else ...[
                  if (state.activeOrders.isNotEmpty) ...[
                    const _SectionTitle(title: AppStrings.currentOrders),
                    const SizedBox(height: AppConstants.spacingMd),
                    ...state.activeOrders.map(
                          (order) => OrderCard(key: ValueKey(order.id), order: order),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                  if (state.pastOrders.isNotEmpty) ...[
                    const _SectionTitle(title: AppStrings.pastOrders),
                    const SizedBox(height: AppConstants.spacingMd),
                    ...state.pastOrders.map(
                          (order) => OrderCard(key: ValueKey(order.id), order: order),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                ],

                const LoyaltyExplainerCard(),
                const SizedBox(height: AppConstants.spacingLg),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int badgeCount;

  const _SectionTitle({required this.title, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: AppConstants.spacingLg,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(child: Text(title, style: AppTextStyles.heading2)),
        if (badgeCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Text(
              '$badgeCount',
              style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary),
            ),
          ),
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXxl),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: AppConstants.iconXl,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text(AppStrings.noOrdersYet, style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            AppStrings.noOrdersYetSubtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}