import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../currency/presentation/widgets/currency_sheet.dart';
import '../../../cart/presentation/widgets/cart_amount.dart';
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
import '../../../fitness/presentation/widgets/specialist_contact.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../../suppliers/presentation/widgets/supplier_order_bar.dart';

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
        actions: [
          BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
            buildWhen: (a, b) => a.product != b.product || a.appliedPrice != b.appliedPrice,
            builder: (context, state) => switch (state.product) {
              final p? when p.pricing == PricingKind.money =>
                CurrencySheetButton(amount: (state.appliedPrice ?? p.effectivePrice) + p.shippingPrice),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
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
                            if (product.pricing == PricingKind.money) ...[
                              const SizedBox(height: AppConstants.spacingXs),
                              Text(
                                product.shippingPrice > 0
                                    ? AppStrings.supplyShippingPerPiece(formatCartAmount(product.shippingPrice, PricingKind.money))
                                    : AppStrings.supplyShippingFree,
                                style: AppTextStyles.caption.copyWith(
                                  color: product.shippingPrice > 0 ? AppColors.goldLight : AppColors.success,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppConstants.spacingSm),
                            Text(
                              product.isInStock ? AppStrings.inStockCount(product.stock) : AppStrings.outOfStock,
                              style: AppTextStyles.body.copyWith(
                                color: !product.isInStock
                                    ? AppColors.error
                                    : product.isLowStock
                                        ? AppColors.warning
                                        : AppColors.success,
                              ),
                            ),
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

    if (!product.isOrderable) return _ConsultBar(productName: product.name);
    return _SupplierGate(product: product, orElse: _cartBar(context, product, cubit));
  }

  Widget _cartBar(BuildContext context, Product product, ProductDetailsCubit cubit) {

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
                      pricing: product.pricing,
                      shippingPerUnit: product.shippingPrice,
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

/// Consult-only products (slimming, medicines…) aren't added to the cart —
/// the specialist orders them for the customer after a WhatsApp consult.
class _ConsultBar extends StatelessWidget {
  final String productName;

  const _ConsultBar({required this.productName});

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
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.consultOnlyNote,
                  textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppConstants.spacingSm),
              CustomButton(
                label: AppStrings.consultSpecialist,
                icon: Icons.chat_outlined,
                onPressed: () => SpecialistContact.open(context, about: productName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the supplier's WhatsApp order bar for supplier products, the cart
/// bar otherwise. The lookup is cached, so it resolves at once after the
/// first product of a supplier.
class _SupplierGate extends StatefulWidget {
  final Product product;
  final Widget orElse;

  const _SupplierGate({required this.product, required this.orElse});

  @override
  State<_SupplierGate> createState() => _SupplierGateState();
}

class _SupplierGateState extends State<_SupplierGate> {
  late final Future<Supplier?> _supplier = supplierOf(widget.product);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Supplier?>(
      future: _supplier,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const SizedBox.shrink();
        final supplier = snap.data;
        return supplier == null ? widget.orElse : SupplierOrderBar(supplier: supplier, productName: widget.product.name);
      },
    );
  }
}
