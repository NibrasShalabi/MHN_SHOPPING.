import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/domain/entities/product.dart';
import '../../../loyalty/presentation/cubits/loyalty_balance_cubit.dart';
import '../cubits/cart_state.dart';
import 'cart_amount.dart';

/// Money and points totals on their own lines, plus the points balance
/// check — shared by the cart bar and the checkout summary.
class CartTotals extends StatelessWidget {
  final CartState cart;
  final TextStyle? style;

  const CartTotals({super.key, required this.cart, this.style});

  @override
  Widget build(BuildContext context) {
    final valueStyle = style ?? AppTextStyles.heading2;
    final balance = context.watch<LoyaltyBalanceCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cart.hasMoneyItems)
          _Line(label: AppStrings.total, value: formatCartAmount(cart.moneyTotal, PricingKind.money), style: valueStyle),
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
