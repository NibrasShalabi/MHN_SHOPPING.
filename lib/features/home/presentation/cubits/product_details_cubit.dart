import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repository/catalog_repository.dart';
import '../../domain/entities/product_variants.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final CatalogRepository _catalogRepository;
  final String productId;

  ProductDetailsCubit(this._catalogRepository, {required this.productId})
      : super(const ProductDetailsState());

  Future<void> load() async {
    emit(state.copyWith(status: ProductDetailsStatus.loading, failure: null));
    try {
      final product = await _catalogRepository.getProduct(productId);
      emit(state.copyWith(status: ProductDetailsStatus.success, product: product));
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

// TODO(cart-feature): hand the product id + quantity to CartCubit.
// Price is deliberately NOT passed along — the order total is computed
// server-side from the product document at checkout time, so a tampered
// client can't set its own price.
}