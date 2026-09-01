import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/support_repository.dart';
import 'rate_app_state.dart';

class RateAppCubit extends Cubit<RateAppState> {
  final SupportRepository _repository;

  RateAppCubit(this._repository) : super(const RateAppState());

  Future<void> load() async {
    emit(state.copyWith(status: RateAppStatus.loading, failure: null));
    try {
      final hasRated = await _repository.hasRated();
      final reviews = await _repository.getReviews();
      emit(state.copyWith(
        status: RateAppStatus.ready,
        hasRated: hasRated,
        reviews: reviews,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RateAppStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  void setStars(int stars) => emit(state.copyWith(stars: stars));

  void updateComment(String comment) => emit(state.copyWith(comment: comment));

  void attachImage(String path) => emit(state.copyWith(imagePath: path));

  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: RateAppStatus.submitting, failure: null));
    try {
      await _repository.submitRating(
        stars: state.stars,
        comment: state.comment.trim().isEmpty ? null : state.comment.trim(),
        imagePath: state.imagePath,
      );
      final reviews = await _repository.getReviews();
      emit(state.copyWith(
        status: RateAppStatus.submitted,
        hasRated: true,
        reviews: reviews,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RateAppStatus.ready,
        failure: mapExceptionToFailure(e),
      ));
    }
  }
}