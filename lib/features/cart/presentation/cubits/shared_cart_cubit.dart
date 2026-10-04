import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/shared_cart_repository.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_cubit.dart';
import 'shared_cart_state.dart';

/// Viewing a cart someone else shared.
///
/// Holds the sender's snapshot and tracks what the viewer copied into
/// their own cart. Writes go through [CartCubit] — this never touches
/// storage directly, so there's still one owner of the user's cart.
class SharedCartCubit extends Cubit<SharedCartState> {
  final SharedCartRepository _repository;
  final CartCubit _cartCubit;
  final String cartId;

  SharedCartCubit(
      this._repository, {
        required CartCubit cartCubit,
        required this.cartId,
      })  : _cartCubit = cartCubit,
        super(const SharedCartState());

  Future<void> load() async {
    emit(state.copyWith(status: SharedCartStatus.loading, failure: null));
    try {
      final items = await _repository.getSharedCart(cartId);
      if (items == null) {
        emit(state.copyWith(status: SharedCartStatus.expired));
        return;
      }
      emit(state.copyWith(status: SharedCartStatus.ready, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: SharedCartStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  void saveItem(CartItem item) {
    if (state.isSaved(item.productId)) return;

    _cartCubit.addItem(item);
    emit(state.copyWith(savedProductIds: {...state.savedProductIds, item.productId}));
  }

  void saveAll() {
    for (final item in state.items) {
      if (state.isSaved(item.productId)) continue;
      _cartCubit.addItem(item);
    }
    emit(state.copyWith(
      savedProductIds: state.items.map((i) => i.productId).toSet(),
    ));
  }
}