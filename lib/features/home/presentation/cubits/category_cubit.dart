import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../data/repository/catalog_repository.dart';
import '../../domain/entities/product_query.dart';
import 'category_state.dart';

/// Paged product grid for a [ProductQuery] — a category page, or the
/// loyalty store (every points-priced product, no category doc).
class CategoryCubit extends SafeCubit<CategoryState> {
  final CatalogRepository _catalogRepository;
  final ProductQuery query;

  CategoryCubit(this._catalogRepository, {required this.query}) : super(const CategoryState());

  Future<void> load({bool forceRefresh = false}) async {
    emit(state.copyWith(status: CategoryStatus.loading, failure: null));
    try {
      final categoryId = query.categoryId;
      final category = categoryId == null
          ? null
          : await _catalogRepository.getCategory(categoryId, forceRefresh: forceRefresh);
      final page = await _catalogRepository.getProducts(query: query, forceRefresh: forceRefresh);
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

  /// [filterId] null selects the "الكل" chip. Pages already opened come
  /// back from the cache, so flipping between filters is free.
  Future<void> selectFilter(String? filterId) async {
    if (filterId == state.selectedFilterId) return;
    emit(state.copyWith(isFiltering: true, selectedFilterId: filterId, clearFilter: filterId == null, failure: null));
    try {
      final page = await _catalogRepository.getProducts(query: query, filterId: filterId);
      emit(state.copyWith(
        products: page.products,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        isFiltering: false,
      ));
    } catch (e) {
      emit(state.copyWith(isFiltering: false, status: CategoryStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }

  /// Guarded so overlapping scroll events can't fire the same request twice.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isFiltering) return;
    emit(state.copyWith(isLoadingMore: true, failure: null));
    try {
      final page = await _catalogRepository.getProducts(
        query: query,
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
      emit(state.copyWith(isLoadingMore: false, failure: mapExceptionToFailure(e)));
    }
  }
}
