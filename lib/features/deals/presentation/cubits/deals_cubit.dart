import 'dart:async';

import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../../home/data/repository/catalog_repository.dart';
import '../../data/repositories/promotion_repository.dart';
import '../../domain/entities/promotion.dart';
import 'deals_state.dart';

/// Live deals: follows the admin's promotions and loads their products in
/// batches of 30 (cached), instead of one read per deal.
class DealsCubit extends SafeCubit<DealsState> {
  final CatalogRepository _catalogRepository;
  final PromotionRepository _promotionRepository;
  StreamSubscription<DealsState>? _sub;

  DealsCubit(this._catalogRepository, this._promotionRepository) : super(const DealsState());

  void load() {
    _sub?.cancel();
    emit(state.copyWith(status: DealsStatus.loading));
    _sub = _promotionRepository.watchActivePromotions().asyncMap(_withProducts).listen(
          emit,
          onError: (Object e) => emit(state.copyWith(status: DealsStatus.failure, failure: mapExceptionToFailure(e))),
        );
  }

  Future<DealsState> _withProducts(List<Promotion> promotions) async {
    final live = promotions.where((p) => !p.isExpired).toList()
      ..sort((a, b) => a.endTime.compareTo(b.endTime));
    final products = {
      for (final p in await _catalogRepository.getProductsByIds(live.map((p) => p.productId).toList())) p.id: p,
    };
    return state.copyWith(
      status: DealsStatus.success,
      items: [
        for (final promo in live)
          if (products[promo.productId] case final product?) DealItem(product: product, promotion: promo),
      ],
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
