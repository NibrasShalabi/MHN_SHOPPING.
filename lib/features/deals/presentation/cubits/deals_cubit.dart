import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../home/data/repository/catalog_repository.dart';
import '../../data/repositories/promotion_repository.dart';
import 'deals_state.dart';

class DealsCubit extends Cubit<DealsState> {
  final CatalogRepository _catalogRepository;
  final PromotionRepository _promotionRepository;

  DealsCubit(this._catalogRepository, this._promotionRepository)
      : super(const DealsState());

  Future<void> load() async {
    emit(state.copyWith(status: DealsStatus.loading));
    try {
      final promotions = await _promotionRepository.getActivePromotions();
      final items = <DealItem>[];
      for (final promo in promotions) {
        try {
          final product = await _catalogRepository.getProduct(promo.productId);
          items.add(DealItem(product: product, promotion: promo));
        } catch (_) {}
      }
      emit(state.copyWith(status: DealsStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(status: DealsStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }
}