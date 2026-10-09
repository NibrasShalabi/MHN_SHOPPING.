import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/widgets/cart_amount.dart';
import '../../../cart/presentation/widgets/cart_totals.dart';
import '../../../home/domain/entities/product.dart';
import '../../../loyalty/presentation/cubits/loyalty_balance_cubit.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import '../../../cart/presentation/cubits/cart_state.dart';
import '../../../currency/presentation/widgets/currency_form.dart';
import '../cubits/checkout_cubit.dart';
import '../cubits/checkout_state.dart';

const _methods = ['trc20', 'bep20', 'erc20', 'sham_cash'];

String _methodLabel(String method) => switch (method) {
  'trc20' => 'USDT — TRC20 (Tron)',
  'bep20' => 'USDT — BEP20 (BNB Smart Chain)',
  'erc20' => 'USDT — ERC20 (Ethereum)',
  'sham_cash' => AppStrings.shamCash,
  _ => method,
};

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _termsAccepted = false;
  final _txidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().loadAddresses();
  }

  @override
  void dispose() {
    _txidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      listenWhen: (prev, curr) => curr.status != prev.status,
      listener: (context, state) {
        if (state.status == CheckoutStatus.success) {
          context.read<CartCubit>().clear();
          context.go(RouteNames.orderConfirmationPath(state.orderId!));
        }
        if (state.status == CheckoutStatus.failure) {
          AppSnackbar.error(
            context,
            state.failure?.message ?? AppStrings.somethingWentWrong,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWine,
          elevation: 0,
          bottom: const AppBarBottomBorder(),
          centerTitle: true,
          title: Text(AppStrings.checkout, style: AppTextStyles.heading2),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.currency_exchange,
                color: AppColors.iconPrimary,
              ),
              tooltip: AppStrings.currencyConverter,
              onPressed: () => _showCurrencyPopup(context),
            ),
          ],
        ),
        body: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, checkoutState) {
            if (checkoutState.status == CheckoutStatus.loadingAddresses ||
                checkoutState.status == CheckoutStatus.initial) {
              return const CustomLoadingIndicator();
            }

            return BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppConstants.spacingMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _OrderSummary(state: cartState),
                            const SizedBox(height: AppConstants.spacingLg),
                            if (cartState.isPointsOnly)
                              Text(
                                AppStrings.pointsOnlyCheckout,
                                style: AppTextStyles.body.copyWith(color: AppColors.goldLight),
                              )
                            else ...[
                              Text(
                                AppStrings.paymentMethod,
                                style: AppTextStyles.heading2,
                              ),
                              const SizedBox(height: AppConstants.spacingMd),
                              _MethodSelector(
                                selected: checkoutState.selectedMethod,
                                onChanged: context
                                    .read<CheckoutCubit>()
                                    .selectMethod,
                              ),
                              const SizedBox(height: AppConstants.spacingMd),
                              _PaymentDetails(
                                checkoutState: checkoutState,
                                txidController: _txidController,
                                onPickFile: _pickReceipt,
                              ),
                            ],
                            const SizedBox(height: AppConstants.spacingLg),
                            _TermsCheckbox(
                              value: _termsAccepted,
                              onChanged: (v) =>
                                  setState(() => _termsAccepted = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _SubmitBar(
                      enabled:
                          _termsAccepted &&
                          checkoutState.status == CheckoutStatus.ready &&
                          (cartState.isPointsOnly || checkoutState.canSubmit) &&
                          cartState.canAffordPoints(context.watch<LoyaltyBalanceCubit>().state),
                      loading:
                          checkoutState.status == CheckoutStatus.submitting,
                      onSubmit: () => context.read<CheckoutCubit>().submit(
                        items: cartState.items,
                        txid: cartState.isPointsOnly || checkoutState.isShamCash
                            ? null
                            : _txidController.text.trim(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickReceipt() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!mounted) return;
    context.read<CheckoutCubit>().setReceiptFile(result.files.single);
  }

  void _showCurrencyPopup(BuildContext context) {
    final state = context.read<CartCubit>().state;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWine,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
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
            CurrencyForm(initialAmount: state.moneyTotal),
            const SizedBox(height: AppConstants.spacingMd),
          ],
        ),
      ),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _MethodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: _methods.map((m) {
        final isSelected = m == selected;
        return GestureDetector(
          onTap: () => onChanged(m),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.ember.withValues(alpha: 0.2)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.iconPrimary : AppColors.border,
                width: isSelected
                    ? AppConstants.borderThick
                    : AppConstants.borderThin,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.iconPrimary,
                    size: AppConstants.iconSm,
                  ),
                  const SizedBox(width: AppConstants.spacingXs),
                ],
                Text(
                  _methodLabel(m),
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? AppColors.iconPrimary
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  final CheckoutState checkoutState;
  final TextEditingController txidController;
  final VoidCallback onPickFile;

  const _PaymentDetails({
    required this.checkoutState,
    required this.txidController,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AddressRow(address: checkoutState.selectedAddress),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.total,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (_, cartState) => Text(
                  formatCartAmount(cartState.moneyTotal, PricingKind.money),
                  style: AppTextStyles.body.copyWith(color: AppColors.gold),
                ),
              ),
            ],
          ),
          if (checkoutState.isShamCash) ...[
            const SizedBox(height: AppConstants.spacingMd),
            _ReceiptPicker(hasReceipt: checkoutState.hasReceipt, onPick: onPickFile),          ] else ...[
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              AppStrings.sendExactAmount,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: txidController,
              style: AppTextStyles.caption,
              decoration: InputDecoration(
                labelText: AppStrings.txid,
                labelStyle: AppTextStyles.caption,
                hintText: AppStrings.txidHint,
                hintStyle: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
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

class _ReceiptPicker extends StatelessWidget {
  final bool hasReceipt;
  final VoidCallback onPick;

  const _ReceiptPicker({required this.hasReceipt, required this.onPick});

  @override
  Widget build(BuildContext context) {
    // بدّل كل checkNull على receiptFile بـ hasReceipt
    // مثلاً:
    return GestureDetector(
      onTap: onPick,
      child: Container(
        // ...
        child: hasReceipt
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.upload_file),
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
            child: Text(
              address,
              style: AppTextStyles.caption.copyWith(color: AppColors.gold),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy_outlined,
              color: AppColors.iconPrimary,
              size: AppConstants.iconMd,
            ),
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
          ...state.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} ×${item.quantity}',
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatCartAmount(item.lineTotal, item.pricing),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: AppColors.border,
            height: AppConstants.spacingLg,
          ),
          CartTotals(cart: state),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            AppStrings.shippingNote,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
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
        constraints: const BoxConstraints(
          minHeight: AppConstants.minTouchTarget,
        ),
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
              child: Text(
                AppStrings.cartTermsLabel,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onSubmit;

  const _SubmitBar({
    required this.enabled,
    required this.loading,
    required this.onSubmit,
  });

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
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppConstants.borderThin,
          ),
        ),
      ),
      child: loading
          ? const CustomLoadingIndicator()
          : CustomButton(
              label: AppStrings.placeOrder,
              icon: Icons.check_circle_outline,
              width: double.infinity,
              onPressed: enabled ? onSubmit : null,
            ),
    );
  }
}
