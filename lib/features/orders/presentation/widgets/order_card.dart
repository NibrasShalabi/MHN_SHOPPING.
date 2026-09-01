import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.dart';
import 'order_status_timeline.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      radius: AppConstants.radiusLg,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(order: order),
            if (order.status.isInterrupted) _InterruptionBanner(order: order),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetaRow(
                    icon: Icons.schedule,
                    label: AppStrings.orderPlacedAt,
                    value: _formatDate(order.createdAt),
                  ),
                  _MetaRow(
                    icon: Icons.hourglass_bottom,
                    label: AppStrings.orderElapsed,
                    value: _formatDuration(order.elapsed),
                  ),
                  if (order.expectedDelivery != null)
                    _MetaRow(
                      icon: Icons.local_shipping_outlined,
                      label: AppStrings.expectedDelivery,
                      value: _formatDate(order.expectedDelivery!),
                    ),
                  _MetaRow(
                    icon: Icons.inventory_2_outlined,
                    label: AppStrings.quantity,
                    value: '${order.itemCount}',
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: AppConstants.spacingMd),
                  if (!order.status.isInterrupted)
                    OrderStatusTimeline(status: order.status),
                  const SizedBox(height: AppConstants.spacingMd),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: AppConstants.spacingSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.total, style: AppTextStyles.body),
                      Flexible(
                        child: Text(
                          '${order.total.toStringAsFixed(0)} ${AppStrings.currencySy}',
                          style: AppTextStyles.heading2.copyWith(color: AppColors.gold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// intl rather than hand-built strings: manual formatting breaks on
  /// locale differences and doesn't pad or order fields correctly.
  static final DateFormat _dateFormat = DateFormat('yyyy/MM/dd — HH:mm', 'ar');

  static String _formatDate(DateTime date) => _dateFormat.format(date);

  static String _formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays} ${AppStrings.days}';
    if (duration.inHours > 0) return '${duration.inHours} ${AppStrings.hours}';
    return '${duration.inMinutes} ${AppStrings.minutes}';
  }
}

class _Header extends StatelessWidget {
  final OrderEntity order;

  const _Header({required this.order});

  Color get _statusColor => switch (order.status) {
    OrderStatus.delivered => AppColors.success,
    OrderStatus.cancelled => AppColors.error,
    OrderStatus.delayed => AppColors.warning,
    _ => AppColors.gold,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceWine,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppConstants.spacingSm,
        runSpacing: AppConstants.spacingXs,
        children: [
          Text(order.id, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(color: _statusColor, width: AppConstants.borderThin),
            ),
            child: Text(
              order.status.label,
              style: AppTextStyles.caption.copyWith(color: _statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Delay/cancellation notice — replaces the timeline rather than sitting
/// next to it, so the user isn't shown a progress bar for an order that
/// isn't progressing.
class _InterruptionBanner extends StatelessWidget {
  final OrderEntity order;

  const _InterruptionBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final color = isCancelled ? AppColors.error : AppColors.warning;

    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.access_time,
            color: color,
            size: AppConstants.iconMd,
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              order.statusNote ??
                  (isCancelled ? AppStrings.orderCancelledNote : AppStrings.orderDelayedNote),
              style: AppTextStyles.caption.copyWith(color: color, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        children: [
          Icon(icon, size: AppConstants.iconSm, color: AppColors.textSecondary),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}