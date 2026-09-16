import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import '../../../cart/presentation/cubits/cart_state.dart';
import '../../../currency/presentation/widgets/currency_form.dart';

enum _PaymentMethod { trc20, bep20, erc20, shamCash }

extension _PaymentMethodX on _PaymentMethod {
  String get label => switch (this) {
    _PaymentMethod.trc20 => 'USDT — TRC20 (Tron)',
    _PaymentMethod.bep20 => 'USDT — BEP20 (BNB Smart Chain)',
    _PaymentMethod.erc20 => 'USDT — ERC20 (Ethereum)',
    _PaymentMethod.shamCash => AppStrings.shamCash,
  };

  // TODO(logic-phase): يجي من remote config
  String get address => switch (this) {
    _PaymentMethod.trc20 => 'TXXX_FAKE_TRC20_ADDRESS',
    _PaymentMethod.bep20 => '0xFAKE_BEP20_ADDRESS',
    _PaymentMethod.erc20 => '0xFAKE_ERC20_ADDRESS',
    _PaymentMethod.shamCash => '09XXXXXXXX',
  };

  bool get hasQr => this == _PaymentMethod.shamCash;
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _termsAccepted = false;
  _PaymentMethod _selected = _PaymentMethod.trc20;
  final _txidController = TextEditingController();

  @override
  void dispose() {
    _txidController.dispose();
    super.dispose();
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
        title: Text(AppStrings.checkout, style: AppTextStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange, color: AppColors.iconPrimary),
            tooltip: AppStrings.currencyConverter,
            onPressed: () => _showCurrencyPopup(context),
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _OrderSummary(state: state),
                      const SizedBox(height: AppConstants.spacingLg),
                      Text(AppStrings.paymentMethod, style: AppTextStyles.heading2),
                      const SizedBox(height: AppConstants.spacingMd),
                      _PaymentMethodSelector(
                        selected: _selected,
                        onChanged: (m) => setState(() => _selected = m),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      _PaymentDetails(
                        method: _selected,
                        subtotal: state.subtotal,
                        txidController: _txidController,
                      ),
                      const SizedBox(height: AppConstants.spacingLg),
                      _TermsCheckbox(
                        value: _termsAccepted,
                        onChanged: (v) => setState(() => _termsAccepted = v),
                      ),
                    ],
                  ),
                ),
              ),
              _SubmitBar(
                enabled: _termsAccepted,
                onSubmit: () => _submitOrder(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCurrencyPopup(BuildContext context) {
    final state = context.read<CartCubit>().state;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWine,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppConstants.spacingMd,
          AppConstants.spacingSm,
          AppConstants.spacingMd,
          AppConstants.spacingMd + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppConstants.spacingXl,
                height: AppConstants.borderThin * 3,
                margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
              ),
            ),
            Text(AppStrings.currencyConverter, style: AppTextStyles.heading2),
            const SizedBox(height: AppConstants.spacingMd),
            CurrencyForm(initialAmount: state.subtotal),
            const SizedBox(height: AppConstants.spacingMd),
          ],
        ),
      ),
    );
  }

  void _submitOrder(BuildContext context, CartState state) {
    // TODO(logic-phase): إرسال الطلب لـ Firebase + Firestore
    AppSnackbar.info(context, AppStrings.orderPlacedSuccessfully);
    Navigator.of(context).pop();
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final _PaymentMethod selected;
  final ValueChanged<_PaymentMethod> onChanged;

  const _PaymentMethodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: _PaymentMethod.values.map((m) {
        final isSelected = m == selected;
        return GestureDetector(
          onTap: () => onChanged(m),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.ember.withValues(alpha: 0.2) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.iconPrimary : AppColors.border,
                width: isSelected ? AppConstants.borderThick : AppConstants.borderThin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_circle, color: AppColors.iconPrimary, size: AppConstants.iconSm),
                  const SizedBox(width: AppConstants.spacingXs),
                ],
                Text(m.label, style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.iconPrimary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  final _PaymentMethod method;
  final double subtotal;
  final TextEditingController txidController;

  const _PaymentDetails({
    required this.method,
    required this.subtotal,
    required this.txidController,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QR — شام كاش بس
          if (method.hasQr) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_2, size: 90, color: AppColors.textDisabled),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    AppStrings.shamCashPending,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
          ],
          // العنوان
          _AddressRow(address: method.address),
          const SizedBox(height: AppConstants.spacingSm),
          // المبلغ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.total, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              Text('\$${subtotal.toStringAsFixed(2)}', style: AppTextStyles.body.copyWith(color: AppColors.gold)),
            ],
          ),
          if (!method.hasQr) ...[
            const SizedBox(height: AppConstants.spacingXs),
            Text(AppStrings.sendExactAmount, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppConstants.spacingMd),
            // TXID
            TextField(
              controller: txidController,
              style: AppTextStyles.caption,
              decoration: InputDecoration(
                labelText: AppStrings.txid,
                labelStyle: AppTextStyles.caption,
                hintText: AppStrings.txidHint,
                hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final String address;
  const _AddressRow({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(address, style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, color: AppColors.iconPrimary, size: AppConstants.iconMd),
            tooltip: AppStrings.copy,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: address));
              AppSnackbar.info(context, AppStrings.copied);
            },
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartState state;
  const _OrderSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.orderSummary, style: AppTextStyles.heading2),
          const SizedBox(height: AppConstants.spacingMd),
          ...state.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${item.name} ×${item.quantity}',
                      style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
                ),
                Text('\$${item.lineTotal.toStringAsFixed(2)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
              ],
            ),
          )),
          const Divider(color: AppColors.border, height: AppConstants.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.total, style: AppTextStyles.body),
              Text('\$${state.subtotal.toStringAsFixed(2)}', style: AppTextStyles.heading2),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(AppStrings.shippingNote,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm),
        constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: value ? AppColors.gold : AppColors.border),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.gold,
              checkColor: AppColors.surfaceDark,
              side: const BorderSide(color: AppColors.border),
            ),
            Expanded(
              child: Text(AppStrings.cartTermsLabel,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onSubmit;
  const _SubmitBar({required this.enabled, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingSm,
        AppConstants.spacingMd,
        AppConstants.spacingMd + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWine,
        border: Border(top: BorderSide(color: AppColors.border, width: AppConstants.borderThin)),
      ),
      child: CustomButton(
        label: AppStrings.placeOrder,
        icon: Icons.check_circle_outline,
        width: double.infinity,
        onPressed: enabled ? onSubmit : null,
      ),
    );
  }
}