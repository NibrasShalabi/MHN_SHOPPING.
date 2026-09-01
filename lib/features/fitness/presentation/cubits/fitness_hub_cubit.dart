import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repository/fitness_repository.dart';
import 'fitness_hub_state.dart';

class FitnessHubCubit extends Cubit<FitnessHubState> {
  final FitnessRepository _repository;

  FitnessHubCubit(this._repository) : super(const FitnessHubState());

  Future<void> load() async {
    emit(state.copyWith(status: FitnessHubStatus.loading, failure: null));
    try {
      final programs = await _repository.getPrograms();
      emit(state.copyWith(status: FitnessHubStatus.success, programs: programs));
    } catch (e) {
      emit(state.copyWith(
        status: FitnessHubStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }
}