import 'dart:async';
import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/cart_repository.dart';
import '../../../home/data/repository/catalog_repository.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_state.dart';

/// Owns the cart for the whole app أ¢â‚¬â€‌ provided above the router so the
/// nav-bar badge and the cart screen always agree, and so adding from a
/// product page doesn't need its own instance.
///
/// Every edit updates the in-memory list immediately and schedules a
/// single debounced write. Round-tripping through the repository on each
/// tap would mean a Firestore read per "+" press once this is wired to
/// Firebase; here the UI is the source of truth between writes, and
/// storage catches up once the user stops tapping.
class CartCubit extends SafeCubit<CartState> {
  final CartRepository _cartRepository;
  final CatalogRepository _catalogRepository;

  Timer? _persistTimer;

  static const Duration _persistDelay = Duration(milliseconds: 700);

  CartCubit(this._cartRepository, this._catalogRepository) : super(const CartState());

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading, failure: null));
    try {
      final items = await _cartRepository.getItems();

      // ط·ع¾ط·آ­ط¸â€ڑط¸â€ڑ ط¸â€¦ط¸â€  ط¸ئ’ط¸â€‍ ط¸â€¦ط¸â€ ط·ع¾ط·آ¬ ط·آ¥ط·آ°ط·آ§ ط¸â€‍ط·آ³ط·آ§ ط¸â€¦ط¸ث†ط·آ¬ط¸ث†ط·آ¯
      // The product is fetched anyway for the availability check — its
      // pricing and supply shipping are re-applied too, so older carts stay correct.
      final unavailable = <String>{};
      final checked = <CartItem>[];
      for (final item in items) {
        try {
          final product = await _catalogRepository.getProduct(item.productId);
          checked.add(item.syncedWith(product));
        } catch (_) {
          unavailable.add(item.productId);
          checked.add(item);
        }
      }

      emit(state.copyWith(
        status: CartStatus.success,
        items: checked,
        unavailableProductIds: unavailable,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  /// Same product, size and colour stack on one line; anything else is a
  /// new line. Refused when it would take the cart past its cap.
  bool addItem(CartItem item) {
    if (item.quantity > state.room) return false;
    final items = [...state.items];
    final index = items.indexWhere((i) => i.lineKey == item.lineKey);
    if (index == -1) {
      items.add(item);
    } else {
      // Latest price, combined quantity.
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + item.quantity,
        priceSnapshot: item.priceSnapshot,
      );
    }
    _emitItems(items);
    return true;
  }

  /// False when the cart is already full.
  bool increaseQuantity(String lineKey) {
    final item = _find(lineKey);
    if (item == null || state.isFull) return false;
    setQuantity(lineKey, item.quantity + 1);
    return true;
  }

  void decreaseQuantity(String lineKey) {
    final item = _find(lineKey);
    if (item == null) return;
    setQuantity(lineKey, item.quantity - 1);
  }

  void setQuantity(String lineKey, int quantity) {
    if (quantity <= 0) {
      removeItem(lineKey);
      return;
    }
    _emitItems([
      for (final item in state.items)
        if (item.lineKey == lineKey) item.copyWith(quantity: quantity) else item,
    ]);
  }

  void removeItem(String lineKey) => _emitItems(state.items.where((i) => i.lineKey != lineKey).toList());

  void clear() => _emitItems(const []);

  CartItem? _find(String lineKey) => state.items.where((i) => i.lineKey == lineKey).firstOrNull;

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