import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/cart_repository.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_state.dart';

/// Owns the cart for the whole app — provided above the router so the
/// nav-bar badge and the cart screen always agree, and so adding from a
/// product page doesn't need its own instance.
///
/// Every edit updates the in-memory list immediately and schedules a
/// single debounced write. Round-tripping through the repository on each
/// tap would mean a Firestore read per "+" press once this is wired to
/// Firebase; here the UI is the source of truth between writes, and
/// storage catches up once the user stops tapping.
class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  Timer? _persistTimer;

  static const Duration _persistDelay = Duration(milliseconds: 700);

  CartCubit(this._cartRepository) : super(const CartState());

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading, failure: null));
    try {
      final items = await _cartRepository.getItems();
      emit(state.copyWith(status: CartStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  void addItem(CartItem item) {
    final items = [...state.items];
    final index = items.indexWhere((i) => i.productId == item.productId);

    if (index == -1) {
      items.add(item);
    } else {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + item.quantity,
      );
    }

    _emitItems(items);
  }

  void increaseQuantity(String productId) {
    final item = _find(productId);
    if (item == null) return;
    setQuantity(productId, item.quantity + 1);
  }

  void decreaseQuantity(String productId) {
    final item = _find(productId);
    if (item == null) return;
    setQuantity(productId, item.quantity - 1);
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final items = [
      for (final item in state.items)
        if (item.productId == productId) item.copyWith(quantity: quantity) else item,
    ];

    _emitItems(items);
  }

  void removeItem(String productId) {
    _emitItems(state.items.where((i) => i.productId != productId).toList());
  }

  void clear() => _emitItems(const []);

  CartItem? _find(String productId) {
    for (final item in state.items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  /// Show the change now, write it shortly after. A burst of taps collapses
  /// into one write instead of one per tap.
  void _emitItems(List<CartItem> items) {
    emit(state.copyWith(status: CartStatus.success, items: items, failure: null));
    _schedulePersist();
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(_persistDelay, _persist);
  }

  Future<void> _persist() async {
    try {
      await _cartRepository.saveItems(state.items);
    } catch (e) {
      emit(state.copyWith(failure: mapExceptionToFailure(e)));
    }
  }

  @override
  Future<void> close() {
    _persistTimer?.cancel();
    // Anything still pending is flushed on the way out, so closing the app
    // right after an edit doesn't lose it.
    unawaited(_persist());
    return super.close();
  }
}