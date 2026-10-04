import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/custom/custom_loading_indicator.dart';
import '../../domain/entities/product.dart';
import '../cubits/product_details_cubit.dart';
import '../cubits/product_details_state.dart';
import '../widgets/expandable_section.dart';
import '../widgets/price_text.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_variant_selector.dart';
import '../widgets/quantity_selector.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProductDetailsCubit>();
    cubit.load();
    cubit.startPromotionRefresh();
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
      ),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          // إشعار تغيير السعر — بعد انتهاء الـ build
          if (state.priceChanged) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) AppSnackbar.info(context, AppStrings.priceUpdated);
            });
          }

          if (state.status == ProductDetailsStatus.loading ||
              state.status == ProductDetailsStatus.initial) {
            return const CustomLoadingIndicator();
          }

          if (state.status == ProductDetailsStatus.failure || state.product == null) {
            return Center(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body,
              ),
            );
          }

          final product = state.product!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImageGallery(imageUrls: product.imageUrls),
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, style: AppTextStyles.heading2),
                            const SizedBox(height: AppConstants.spacingSm),
                            PriceText(
                              product: product,
                              style: AppTextStyles.heading1.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (!product.isInStock) ...[
                              const SizedBox(height: AppConstants.spacingSm),
                              Text(
                                AppStrings.outOfStock,
                                style: AppTextStyles.body.copyWith(color: AppColors.error),
                              ),
                            ],
                            const SizedBox(height: AppConstants.spacingLg),
                            ProductVariantSelector(
                              clothingSizes: product.clothingSizes,
                              shoeSizes: product.shoeSizes,
                              colors: product.colors,
                              sizeGuide: product.sizeGuide,
                              selectedClothingSize: state.clothingSize,
                              selectedShoeSize: state.shoeSize,
                              selectedColor: state.color,
                              onClothingSizeSelected:
                              context.read<ProductDetailsCubit>().selectClothingSize,
                              onShoeSizeSelected:
                              context.read<ProductDetailsCubit>().selectShoeSize,
                              onColorSelected:
                              context.read<ProductDetailsCubit>().selectColor,
                            ),
                            ..._sections(product),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _BottomBar(state: state),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _sections(Product product) {
    final sections = <Widget>[];

    void add(String title, String? content, {bool expanded = false}) {
      if (content == null || content.trim().isEmpty) return;
      sections.add(ExpandableSection(
        title: title,
        content: content,
        initiallyExpanded: expanded,
      ));
    }

    add(AppStrings.productDescription, product.description, expanded: true);
    add(AppStrings.ingredients, product.ingredients);
    add(AppStrings.benefits, product.benefits);
    add(AppStrings.usageInstructions, product.usage);

    return sections;
  }
}

class _BottomBar extends StatelessWidget {
  final ProductDetailsState state;
  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final product = state.product!;
    final cubit = context.read<ProductDetailsCubit>();

    if (!product.isOrderable) return const SizedBox.shrink();

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
          child: Wrap(
            spacing: AppConstants.spacingMd,
            runSpacing: AppConstants.spacingSm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              QuantitySelector(
                quantity: state.quantity,
                canIncrease: state.canIncrease,
                canDecrease: state.canDecrease,
                onIncrease: cubit.increaseQuantity,
                onDecrease: cubit.decreaseQuantity,
              ),
              CustomButton(
                label: AppStrings.addToCart,
                icon: Icons.shopping_cart_outlined,
                onPressed: product.isInStock && state.hasRequiredVariants
                    ? () {
                  context.read<CartCubit>().addItem(
                    CartItem(
                      productId: product.id,
                      name: product.name,
                      imageUrl: product.thumbnailUrl,
                      priceSnapshot: state.appliedPrice ?? product.effectivePrice,
                      quantity: state.quantity,
                    ),
                  );
                  AppSnackbar.success(context, AppStrings.addedToCart);
                }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}