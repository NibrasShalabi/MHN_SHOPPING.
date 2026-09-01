import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_dialog.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubits/cart_cubit.dart';
import '../cubits/cart_state.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  /// Local to the screen: the user has to re-confirm on every checkout,
  /// so this deliberately isn't persisted anywhere.
  bool _termsAccepted = false;

  Future<void> _confirmClearCart(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    await showCustomDialog(
      context,
      title: AppStrings.clearCart,
      message: AppStrings.clearCartConfirm,
      confirmText: AppStrings.confirm,
      cancelText: AppStrings.cancel,
      onConfirm: () {
        cubit.clear();
        if (!mounted) return;
        setState(() => _termsAccepted = false);
        AppSnackbar.info(context, AppStrings.cartCleared);
      },
    );
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
        title: Text(AppStrings.cart, style: AppTextStyles.heading2),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            buildWhen: (previous, current) => previous.isEmpty != current.isEmpty,
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: AppStrings.shareCart,
                icon: const Icon(Icons.share_outlined, color: AppColors.gold),
                onPressed: () => _shareCart(context, state),
              );
            },
          ),
          BlocBuilder<CartCubit, CartState>(
            buildWhen: (previous, current) => previous.isEmpty != current.isEmpty,
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: AppStrings.clearCart,
                icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                onPressed: () => _confirmClearCart(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading || state.status == CartStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.isEmpty) return const _EmptyCart();

          final cubit = context.read<CartCubit>();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return CartItemTile(
                      key: ValueKey(item.productId),
                      item: item,
                      onIncrease: () => cubit.increaseQuantity(item.productId),
                      onDecrease: () => cubit.decreaseQuantity(item.productId),
                      onRemove: () => cubit.removeItem(item.productId),
                    );
                  },
                ),
              ),
              _CheckoutBar(
                state: state,
                termsAccepted: _termsAccepted,
                onTermsChanged: (value) => setState(() => _termsAccepted = value),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: AppConstants.iconXl,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              AppStrings.emptyCart,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              AppStrings.emptyCartSubtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Total + checkout button, pinned so it stays reachable with a long list.
class _CheckoutBar extends StatelessWidget {
  final CartState state;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;

  const _CheckoutBar({
    required this.state,
    required this.termsAccepted,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWine,
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppConstants.borderThin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SummaryRow(
                label: AppStrings.subtotal,
                value: '${state.subtotal.toStringAsFixed(0)} ${AppStrings.currencySy}',
              ),
              const SizedBox(height: AppConstants.spacingXs),
              // Shipping is quoted by the courier per area, so the amount
              // isn't known here. Naming the line anyway is what stops the
              // subtotal from being mistaken for the final bill.
              _SummaryRow(
                label: AppStrings.shipping,
                value: AppStrings.shippingNote,
                isMuted: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
                child: Divider(color: AppColors.border, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.total,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Flexible(
                    child: Text(
                      '${state.subtotal.toStringAsFixed(0)} ${AppStrings.currencySy}+',
                      style: AppTextStyles.heading2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),
              _TermsCheckbox(value: termsAccepted, onChanged: onTermsChanged),
              const SizedBox(height: AppConstants.spacingSm),
              CustomButton(
                label: AppStrings.proceedToCheckout,
                icon: Icons.chat_outlined,
                width: double.infinity,
                // Disabled until the terms are ticked.
                //
                // TODO(logic-phase): this is a UX gate, NOT the real one.
                // The acceptance flag has to be written on the order
                // document and re-checked in the Cloud Function that
                // creates it — otherwise a tampered client can submit an
                // order with no recorded consent to pay.
                //
                // TODO(logic-phase): create the order server-side FIRST,
                // then open WhatsApp with its id. Sending the message
                // without a persisted order means a lost chat is a lost
                // order, and the total in the text must come from the
                // server, never from this screen's arithmetic.
                onPressed: termsAccepted ? () => _sendOrderToWhatsapp(context, state) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Publishes the cart and shares the link.
///
/// TODO(logic-phase): call SharedCartRepository.shareCart to get a real id
/// and build the link from it, then hand it to share_plus so the user can
/// send it anywhere rather than only WhatsApp.
Future<void> _shareCart(BuildContext context, CartState state) async {
  final lines = state.items.map((item) => '• ${item.name} ×${item.quantity}').join('\n');
  final message = '${AppStrings.cartShareMessage}\n$lines';

  final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    AppSnackbar.error(context, AppStrings.somethingWentWrong);
  }
}

/// Hands the order to the admin over WhatsApp — there is no checkout
/// screen; payment is arranged in that conversation.
Future<void> _sendOrderToWhatsapp(BuildContext context, CartState state) async {
  final lines = state.items
      .map((item) => '• ${item.name} ×${item.quantity}')
      .join('\n');

  final message = '${AppStrings.whatsappOrderHeader}\n$lines\n\n'
      '${AppStrings.total}: ${state.subtotal.toStringAsFixed(0)} ${AppStrings.currencySy}';

  // TODO(logic-phase): the admin number comes from remote config, and the
  // message should carry the server-issued order id.
  final uri = Uri.parse(
    'https://wa.me/${AppStrings.adminWhatsappNumber}?text=${Uri.encodeComponent(message)}',
  );

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    AppSnackbar.error(context, AppStrings.somethingWentWrong);
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
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMuted;

  const _SummaryRow({required this.label, required this.value, this.isMuted = false});

  @override
  Widget build(BuildContext context) {
    final style = isMuted
        ? AppTextStyles.caption.copyWith(color: AppColors.textSecondary)
        : AppTextStyles.body;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Flexible(
          child: Text(
            value,
            style: style,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}