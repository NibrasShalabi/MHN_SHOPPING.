import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_dialog.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../cubits/cart_cubit.dart';
import '../cubits/cart_state.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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
        AppSnackbar.info(context, AppStrings.cartCleared);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppConstants.isWideScreen(context)
          ? null
          : AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        bottom: const AppBarBottomBorder(),
        centerTitle: true,
        title: Text(AppStrings.cart, style: AppTextStyles.heading2),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            buildWhen: (p, c) => p.isEmpty != c.isEmpty,
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
                      isUnavailable: state.unavailableProductIds.contains(item.productId),
                      onIncrease: () => cubit.increaseQuantity(item.productId),
                      onDecrease: () => cubit.decreaseQuantity(item.productId),
                      onRemove: () => cubit.removeItem(item.productId),
                    );
                  },
                ),
              ),
              _CheckoutBar(state: state),
            ],
          );
        },
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final CartState state;
  const _CheckoutBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWine,
        border: Border(top: BorderSide(color: AppColors.border, width: AppConstants.borderThin)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.total, style: AppTextStyles.caption),
                  Text('\$${state.subtotal.toStringAsFixed(2)}', style: AppTextStyles.heading2),
                ],
              ),
              CustomButton(
                label: state.unavailableProductIds.isEmpty
                    ? AppStrings.proceedToCheckout
                    : AppStrings.cartHasUnavailableItems,
                icon: Icons.arrow_back_ios,
                onPressed: state.unavailableProductIds.isEmpty
                    ? () => context.push(RouteNames.checkout)
                    : null,
              ),
            ],
          ),
        ),
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
            const Icon(Icons.shopping_cart_outlined, size: AppConstants.iconXl, color: AppColors.textDisabled),
            const SizedBox(height: AppConstants.spacingLg),
            Text(AppStrings.emptyCart, style: AppTextStyles.heading2, textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.spacingSm),
            Text(AppStrings.emptyCartSubtitle, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}