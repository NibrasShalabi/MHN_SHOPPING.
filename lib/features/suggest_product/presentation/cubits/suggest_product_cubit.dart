import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/suggest_product_repository.dart';
import '../../domain/entities/product_suggestion.dart';
import 'suggest_product_state.dart';

class SuggestProductCubit extends Cubit<SuggestProductState> {
  final SuggestProductRepository _repository;

  SuggestProductCubit(this._repository) : super(const SuggestProductState());

  Future<void> submit(ProductSuggestion suggestion) async {
    emit(state.copyWith(status: SuggestProductStatus.submitting, failure: null));
    try {
      await _repository.submit(suggestion);
      emit(state.copyWith(status: SuggestProductStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SuggestProductStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }
}