import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../deals/data/repositories/promotion_repository.dart';
import '../../../deals/domain/entities/promotion.dart';
import '../../data/repository/catalog_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/promo_banner.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final CatalogRepository _catalogRepository;
  final PromotionRepository _promotionRepository;

  HomeCubit(this._catalogRepository, this._promotionRepository)
      : super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading, failure: null));
    try {
      final results = await Future.wait([
        _catalogRepository.getPromoBanners(),
        _catalogRepository.getCategories(),
        _promotionRepository.getActivePromotions(),
      ]);

      final promotions = results[2] as List<Promotion>;

      // جيب منتجات الـ deals
      final dealProducts = <Product>[];
      for (final promo in promotions) {
        try {
          final product = await _catalogRepository.getProduct(promo.productId);
          dealProducts.add(product);
        } catch (_) {}
      }

      emit(state.copyWith(
        status: HomeStatus.success,
        banners: results[0] as List<PromoBanner>,
        categories: results[1] as List<Category>,
        promotions: promotions,
        dealProducts: dealProducts,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }
}