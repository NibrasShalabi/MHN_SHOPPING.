import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/product.dart';
import '../../../loyalty/presentation/cubits/loyalty_balance_cubit.dart';
import '../cubits/cart_state.dart';
import '../../../checkout/domain/entities/order_breakdown.dart';
import 'cart_amount.dart';

/// Money and points totals on their own lines, plus the points balance
/// check — shared by the cart bar and the checkout summary.
class CartTotals extends StatelessWidget {
  final CartState cart;
  final TextStyle? style;

  /// At checkout — adds delivery for the customer's governorate and the amount due.
  final OrderBreakdown? breakdown;
  final String? governorate;

  const CartTotals({super.key, required this.cart, this.style, this.breakdown, this.governorate});

  @override
  Widget build(BuildContext context) {
    final valueStyle = style ?? AppTextStyles.heading2;
    final balance = context.watch<LoyaltyBalanceCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cart.hasMoneyItems) ...[
          _Line(label: AppStrings.itemsTotalLabel, value: _money(breakdown?.itemsTotal ?? cart.moneyTotal), style: AppTextStyles.body),
          if ((breakdown?.supplyShipping ?? cart.supplyShipping) > 0)
            _Line(label: AppStrings.supplyShippingLabel, value: _money(breakdown?.supplyShipping ?? cart.supplyShipping), style: AppTextStyles.body),
          if (breakdown case final b?) ...[
            _Line(
              label: governorate == null ? AppStrings.deliveryLabel : AppStrings.deliveryTo(governorate!),
              value: _money(b.deliveryFee),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            _Line(label: AppStrings.amountDue, value: _money(b.total), style: valueStyle),
          ] else ...[
            _Line(label: AppStrings.total, value: _money(cart.moneyTotal + cart.supplyShipping), style: valueStyle),
            Text(AppStrings.deliveryAtCheckout, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ],
        if (cart.hasPointsItems) ...[
          _Line(
            label: AppStrings.pointsTotal,
            value: formatCartAmount(cart.pointsTotal.toDouble(), PricingKind.points),
            style: valueStyle,
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            cart.pointsTotal > balance ? AppStrings.notEnoughPointsDetail(cart.pointsTotal, balance) : AppStrings.pointsBalance(balance),
            style: AppTextStyles.caption.copyWith(
              color: cart.pointsTotal > balance ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle style;

  const _Line({required this.label, required this.value, required this.style});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: style),
        ],
      );
}

String _money(double amount) => formatCartAmount(amount, PricingKind.money);
