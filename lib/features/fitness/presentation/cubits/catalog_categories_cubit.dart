import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../home/data/repository/catalog_repository.dart';
import '../../../home/domain/entities/category.dart';
import 'catalog_categories_state.dart';

/// Loads the category list for one scope.
///
/// The store grid on the home screen and the fitness shelf need the same
/// thing from the same repository, differing only by scope — so they share
/// this instead of each growing a cubit of its own.
class CatalogCategoriesCubit extends Cubit<CatalogCategoriesState> {
  final CatalogRepository _repository;
  final CatalogScope scope;

  CatalogCategoriesCubit(this._repository, {required this.scope})
      : super(const CatalogCategoriesState());

  Future<void> load({bool forceRefresh = false}) async {
    emit(state.copyWith(status: CatalogCategoriesStatus.loading, failure: null));
    try {
      final categories =
      await _repository.getCategories(scope: scope, forceRefresh: forceRefresh);
      emit(state.copyWith(
        status: CatalogCategoriesStatus.success,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CatalogCategoriesStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }
}