import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../data/repository/catalog_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/promo_banner.dart';
import 'home_state.dart';
class HomeCubit extends Cubit<HomeState> {
  final CatalogRepository _catalogRepository;

  HomeCubit(this._catalogRepository) : super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading, failure: null));
    try {
      final results = await Future.wait([
        _catalogRepository.getPromoBanners(),
        _catalogRepository.getCategories(),
      ]);
      emit(state.copyWith(
        status: HomeStatus.success,
        banners: results[0] as List<PromoBanner>,
        categories: results[1] as List<Category>,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }
}