import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../../deals/data/repositories/promotion_repository.dart';
import '../../../deals/domain/entities/promotion.dart';
import '../../data/repository/catalog_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/promo_banner.dart';
import 'home_state.dart';

class HomeCubit extends SafeCubit<HomeState> {
  final CatalogRepository _catalogRepository;
  final PromotionRepository _promotionRepository;

  HomeCubit(this._catalogRepository, this._promotionRepository)
      : super(const HomeState());

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: HomeStatus.loading, failure: null));
    try {
      final results = await Future.wait([
        _catalogRepository.getPromoBanners(),
        _catalogRepository.getCategories(),
        _promotionRepository.getActivePromotions(),
      ]);

      final promotions = results[2] as List<Promotion>;

      // One batched read (30 per query, cached) instead of one per deal.
      final dealProducts = await _catalogRepository.getProductsByIds([for (final p in promotions) p.productId]);

      if (isClosed) return;
      emit(state.copyWith(
        status: HomeStatus.success,
        banners: results[0] as List<PromoBanner>,
        categories: results[1] as List<Category>,
        promotions: promotions,
        dealProducts: dealProducts,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: HomeStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }}