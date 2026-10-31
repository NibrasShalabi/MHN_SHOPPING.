import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/payment_methods.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/content_width.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/order_entity.dart';
import '../cubits/orders_cubit.dart';
import '../cubits/orders_state.dart';
import '../widgets/order_card.dart';

/// One order in full. Read from the live orders list the app already
/// listens to — no extra Firestore read, and status changes show here too.
class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        centerTitle: true,
        bottom: const AppBarBottomBorder(),
        title: Text(AppStrings.orderDetailsTitle, style: AppTextStyles.heading2),
      ),
      body: ContentWidth(
        maxWidth: 720,
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            final order = state.orders.where((o) => o.id == orderId).firstOrNull;
            if (order != null) return _Details(order: order);
            if (state.status == OrdersStatus.initial || state.status == OrdersStatus.loading) {
              return const CustomLoadingIndicator();
            }
            return Center(child: Text(AppStrings.orderNotFound, style: AppTextStyles.body));
          },
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final OrderEntity order;

  const _Details({required this.order});

  static String _money(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final address = [?order.governorate, ?order.area].join(' — ');
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        OrderCard(order: order),
        _Section(
          title: AppStrings.orderItems,
          children: [for (final line in order.lines) _LineTile(line: line)],
        ),
        _Section(
          title: AppStrings.total,
          children: [
            _Row(AppStrings.itemsTotalLabel, _money(order.itemsTotal)),
            if (order.supplyShipping > 0) _Row(AppStrings.supplyShippingLabel, _money(order.supplyShipping)),
            _Row(AppStrings.deliveryLabel, _money(order.deliveryFee)),
            if (order.pointsTotal > 0) _Row(AppStrings.pointsUnit, '${order.pointsTotal}'),
            _Row(AppStrings.amountDue, _money(order.total), strong: true),
          ],
        ),
        _Section(
          title: AppStrings.orderPayment,
          children: [
            if (order.paymentMethod case final m?) _Row(AppStrings.orderPayment, paymentMethodLabel(m)),
            if (order.txid case final t?) _Row(AppStrings.orderTxid, t),
            if (order.paymentStatus case final s?)
              _Row('', switch (s) {
                'verified' => AppStrings.paymentVerified,
                'rejected' => AppStrings.paymentRejectedShort,
                _ => AppStrings.paymentPending,
              }),
          ],
        ),
        if (address.isNotEmpty) _Section(title: AppStrings.orderDeliveryTo, children: [_Row('', address)]),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      radius: AppConstants.radiusLg,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.heading2.copyWith(color: AppColors.gold)),
          const SizedBox(height: AppConstants.spacingSm),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _Row(this.label, this.value, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    final style = strong ? AppTextStyles.heading2.copyWith(color: AppColors.gold) : AppTextStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary))),
          Flexible(child: Text(value, style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  final OrderLine line;

  const _LineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(Icons.image_outlined, color: AppColors.textSecondary);
    final variant = [?line.size, ?line.colorName].join(' · ');
    final price = line.isPoints
        ? '${line.lineTotal.toStringAsFixed(0)} ${AppStrings.pointsUnit}'
        : '\$${line.lineTotal.toStringAsFixed(2)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: SizedBox.square(
              dimension: 48,
              child: line.imageUrl == null
                  ? placeholder
                  : Image.network(line.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.name, style: AppTextStyles.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(
                  variant.isEmpty ? '× ${line.quantity}' : '$variant  × ${line.quantity}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(price, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
