import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../home/data/repository/catalog_repository.dart';
import 'suppliers_state.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final CatalogRepository _repository;

  SuppliersCubit(this._repository) : super(const SuppliersState());

  Future<void> load({bool forceRefresh = false}) async {
    emit(state.copyWith(status: SuppliersStatus.loading, failure: null));
    try {
      final suppliers = await _repository.getSuppliers(forceRefresh: forceRefresh);
      emit(state.copyWith(status: SuppliersStatus.success, suppliers: suppliers));
    } catch (e) {
      emit(state.copyWith(status: SuppliersStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }
}