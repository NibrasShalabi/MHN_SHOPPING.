import 'dart:async';
import '../../../../core/bloc/safe_cubit.dart';

import '../../../../core/error/failures.dart';
import '../../data/repository/catalog_repository.dart';
import '../../domain/entities/product_variants.dart';
import '../../../deals/data/repositories/promotion_repository.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends SafeCubit<ProductDetailsState> {
  final CatalogRepository _catalogRepository;
  final PromotionRepository _promotionRepository;
  final String productId;

  Timer? _refreshTimer;

  ProductDetailsCubit(
      this._catalogRepository,
      this._promotionRepository, {
        required this.productId,
      }) : super(const ProductDetailsState());

  /// ط¸ظ¹ط¸عˆط·آ´ط·ط›ط¸â€کط¸â€‍ refresh ط¸ئ’ط¸â€‍ ط·آ¯ط¸â€ڑط¸ظ¹ط¸â€ڑط·آ© ط¸â€‍ط¸â€‍ط·ع¾ط·آ­ط¸â€ڑط¸â€ڑ ط¸â€¦ط¸â€  ط·آ§ط¸â€ ط·ع¾ط¸â€،ط·آ§ط·طŒ ط·آ§ط¸â€‍ط¸â‚¬ promotion
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

      // ط·آ¬ط¸ظ¹ط·آ¨ ط·آ§ط¸â€‍ط¸â‚¬ promotion ط·آ¥ط¸â€  ط¸ظ¾ط¸ظ¹ ط¸ث†ط·آ·ط·آ¨ط¸â€ڑ ط·آ§ط¸â€‍ط·آ³ط·آ¹ط·آ± ط·آ§ط¸â€‍ط¸â€¦ط·آ®ط¸ظ¾ط·آ¶
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