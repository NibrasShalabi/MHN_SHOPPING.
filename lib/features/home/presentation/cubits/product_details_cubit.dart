import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repository/catalog_repository.dart';
import '../../domain/entities/product_variants.dart';
import '../../../deals/data/repositories/promotion_repository.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final CatalogRepository _catalogRepository;
  final PromotionRepository _promotionRepository;
  final String productId;

  Timer? _refreshTimer;

  ProductDetailsCubit(
      this._catalogRepository,
      this._promotionRepository, {
        required this.productId,
      }) : super(const ProductDetailsState());

  /// يُشغّل refresh كل دقيقة للتحقق من انتهاء الـ promotion
  void startPromotionRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) => load());
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> load() async {
    emit(state.copyWith(status: ProductDetailsStatus.loading, failure: null));
    try {
      final product = await _catalogRepository.getProduct(productId);

      // جيب الـ promotion إن في وطبق السعر المخفض
      final discountPct = await _promotionRepository.getActiveDiscountPercentage(productId);
      final appliedPrice = discountPct > 0
          ? product.price * (1 - discountPct / 100)
          : product.effectivePrice;

      final prevPrice = state.appliedPrice;
      emit(state.copyWith(
        status: ProductDetailsStatus.success,
        product: product,
        appliedPrice: appliedPrice,
        priceChanged: prevPrice != null && prevPrice != appliedPrice,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductDetailsStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  void increaseQuantity() {
    if (!state.canIncrease) return;
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void decreaseQuantity() {
    if (!state.canDecrease) return;
    emit(state.copyWith(quantity: state.quantity - 1));
  }

  void selectClothingSize(ClothingSize size) =>
      emit(state.copyWith(clothingSize: size));

  void selectShoeSize(int size) => emit(state.copyWith(shoeSize: size));

  void selectColor(ProductColor color) => emit(state.copyWith(color: color));
}