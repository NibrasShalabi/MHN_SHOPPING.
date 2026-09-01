import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/cart_item.dart';
import '../cubits/shared_cart_cubit.dart';
import '../cubits/shared_cart_state.dart';

/// A cart someone shared, opened from a link.
///
/// Read-only: the viewer copies what they want into their own cart, item
/// by item or all at once, and the page is done. It's a snapshot, so it
/// deliberately doesn't offer quantity edits or removal — those would
/// imply the viewer is changing the sender's cart.
class SharedCartPage extends StatefulWidget {
  const SharedCartPage({super.key});

  @override
  State<SharedCartPage> createState() => _SharedCartPageState();
}

class _SharedCartPageState extends State<SharedCartPage> {
  @override
  void initState() {
    super.initState();
    context.read<SharedCartCubit>().load();
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
        title: Text(AppStrings.sharedCartTitle, style: AppTextStyles.heading2),
      ),
      body: BlocBuilder<SharedCartCubit, SharedCartState>(
        builder: (context, state) {
          if (state.status == SharedCartStatus.loading) {
            return const CustomLoadingIndicator();
          }

          if (state.status == SharedCartStatus.expired) {
            return _Message(text: AppStrings.sharedCartExpired);
          }

          if (state.status == SharedCartStatus.failure) {
            return _Message(
              text: state.failure?.message ?? AppStrings.somethingWentWrong,
            );
          }

          final cubit = context.read<SharedCartCubit>();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  children: [
                    SurfaceCard(
                      borderColor: AppColors.gold,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.share_outlined,
                            size: AppConstants.iconMd,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          Expanded(
                            child: Text(
                              AppStrings.sharedCartIntro,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    ...state.items.map(
                          (item) => _SharedItemTile(
                        key: ValueKey(item.productId),
                        item: item,
                        isSaved: state.isSaved(item.productId),
                        onSave: () {
                          cubit.saveItem(item);
                          AppSnackbar.success(context, AppStrings.itemSaved);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _SaveAllBar(
                allSaved: state.allSaved,
                onSaveAll: () {
                  cubit.saveAll();
                  AppSnackbar.success(context, AppStrings.cartSaved);
                },
                onClose: () => Navigator.of(context).maybePop(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SharedItemTile extends StatelessWidget {
  final CartItem item;
  final bool isSaved;
  final VoidCallback onSave;

  const _SharedItemTile({
    super.key,
    required this.item,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO(logic-phase): CachedNetworkImage with the thumbnail variant.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: Container(
              width: AppConstants.cartThumbSize,
              height: AppConstants.cartThumbSize,
              color: AppColors.surfaceDark,
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.textDisabled,
                size: AppConstants.iconMd,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.body, maxLines: 2),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  '${item.lineTotal.toStringAsFixed(0)} ${AppStrings.currencySy}'
                      '  ×${item.quantity}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gold),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          // Turns into a static check once copied: a live button here
          // would quietly double the quantity on a second tap.
          isSaved
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingSm),
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: AppConstants.iconMd,
            ),
          )
              : CustomButton(
            label: AppStrings.saveItem,
            isOutlined: true,
            height: AppConstants.minTouchTarget,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _SaveAllBar extends StatelessWidget {
  final bool allSaved;
  final VoidCallback onSaveAll;
  final VoidCallback onClose;

  const _SaveAllBar({
    required this.allSaved,
    required this.onSaveAll,
    required this.onClose,
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
          child: CustomButton(
            label: allSaved ? AppStrings.ok : AppStrings.saveWholeCart,
            icon: allSaved ? Icons.check : Icons.shopping_cart_checkout,
            width: double.infinity,
            // Once everything is copied the page has nothing left to do,
            // so the same button becomes the way out.
            onPressed: allSaved ? onClose : onSaveAll,
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.link_off,
              size: AppConstants.iconXl,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              text,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}