import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repository/catalog_repository.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CatalogRepository _catalogRepository;
  final String categoryId;

  CategoryCubit(this._catalogRepository, {required this.categoryId})
      : super(const CategoryState());

  Future<void> load({bool forceRefresh = false}) async {
    emit(state.copyWith(status: CategoryStatus.loading, failure: null));
    try {
      final category = await _catalogRepository.getCategory(
        categoryId,
        forceRefresh: forceRefresh,
      );
      final page = await _catalogRepository.getProducts(
        categoryId: categoryId,
        forceRefresh: forceRefresh,
      );
      emit(state.copyWith(
        status: CategoryStatus.success,
        category: category,
        products: page.products,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        clearFilter: true,
      ));
    } catch (e) {
      emit(state.copyWith(status: CategoryStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }

  /// [filterId] null selects the "الكل" chip. Results come back from the
  /// cache when the user flips between filters they already opened, so
  /// this costs nothing after the first tap.
  Future<void> selectFilter(String? filterId) async {
    if (filterId == state.selectedFilterId) return;

    emit(state.copyWith(
      isFiltering: true,
      selectedFilterId: filterId,
      clearFilter: filterId == null,
      failure: null,
    ));

    try {
      final page = await _catalogRepository.getProducts(
        categoryId: categoryId,
        filterId: filterId,
      );
      emit(state.copyWith(
        products: page.products,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        isFiltering: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isFiltering: false,
        status: CategoryStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  /// Appends the next page. Guarded so overlapping scroll events can't
  /// fire the same request twice.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isFiltering) return;

    emit(state.copyWith(isLoadingMore: true, failure: null));

    try {
      final page = await _catalogRepository.getProducts(
        categoryId: categoryId,
        filterId: state.selectedFilterId,
        cursor: state.nextCursor,
      );
      emit(state.copyWith(
        products: [...state.products, ...page.products],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        failure: mapExceptionToFailure(e),
      ));
    }
  }
}