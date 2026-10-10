import 'dart:async';

import '../../../home/domain/entities/product.dart';
import '../../domain/entities/promotion.dart';
import 'promotion_repository.dart';

/// The active fire deals, followed live by one listener for the whole app.
/// Every product the catalog hands out passes through [apply], so a deal
/// shows the same price in its category, the cart, the product page and
/// fire deals — and drops back on its own when the deal ends.
class LivePromotions {
  final PromotionRepository _repository;
  final _ready = Completer<void>();
  final _changes = StreamController<List<Promotion>>.broadcast();
  Map<String, Promotion> _best = const {};
  List<Promotion> _active = const [];
  StreamSubscription<List<Promotion>>? _sub;

  LivePromotions(this._repository);

  /// Completes after the first snapshot (or failure — prices then fall back
  /// to the product's own discount rather than blocking the catalog).
  Future<void> get ready {
    _sub ??= _repository.watchActivePromotions().listen(_update, onError: (_) => _complete());
    return _ready.future;
  }

  /// The live deals now, then on every change — for the fire deals badge.
  Stream<List<Promotion>> watch() async* {
    await ready;
    yield _active;
    yield* _changes.stream;
  }

  void _update(List<Promotion> promotions) {
    final best = <String, Promotion>{};
    for (final p in promotions) {
      if (p.isExpired) continue;
      final current = best[p.productId];
      if (current == null || p.discountPercentage > current.discountPercentage) best[p.productId] = p;
    }
    _best = best;
    _active = promotions.where((p) => !p.isExpired).toList();
    _changes.add(_active);
    _complete();
  }

  void _complete() {
    if (!_ready.isCompleted) _ready.complete();
  }

  /// A live deal wins over the product's own discount — the same rule checkout uses.
  Product apply(Product product) {
    final promo = _best[product.id];
    if (promo == null || promo.isExpired) return product;
    return product.withDiscount(promo.discountPercentage, promo.endTime);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _changes.close();
  }
}
