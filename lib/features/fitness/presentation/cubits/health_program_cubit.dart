import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../data/repository/fitness_repository.dart';
import '../../domain/entities/dynamic_form_field.dart';
import 'health_program_state.dart';

class HealthProgramCubit extends Cubit<HealthProgramState> {
  final FitnessRepository _repository;
  final String programId;

  HealthProgramCubit(this._repository, {required this.programId})
      : super(const HealthProgramState());

  Future<void> load() async {
    emit(state.copyWith(status: HealthProgramStatus.loading, failure: null));
    try {
      final program = await _repository.getProgram(programId);
      emit(state.copyWith(status: HealthProgramStatus.ready, program: program));
    } catch (e) {
      emit(state.copyWith(
        status: HealthProgramStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  void updateAnswer(String fieldId, dynamic value) {
    final answers = Map<String, dynamic>.from(state.answers)..[fieldId] = value;

    // Clear this field's error as soon as it's touched — leaving stale red
    // text under a field the user just fixed reads as broken.
    final errors = Map<String, String>.from(state.errors)..remove(fieldId);

    emit(state.copyWith(answers: answers, errors: errors));
  }

  Future<void> submit() async {
    final program = state.program;
    if (program == null) return;

    final errors = _validate(program.fields);
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }

    emit(state.copyWith(status: HealthProgramStatus.submitting, failure: null));
    try {
      await _repository.submitProgramForm(programId: programId, answers: state.answers);
      emit(state.copyWith(status: HealthProgramStatus.submitted));
    } catch (e) {
      emit(state.copyWith(
        status: HealthProgramStatus.ready,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  Map<String, String> _validate(List<DynamicFormField> fields) {
    final errors = <String, String>{};

    for (final field in fields) {
      if (!field.isRequired) continue;

      final value = state.answers[field.id];
      final isEmpty = value == null ||
          (value is String && value.trim().isEmpty) ||
          (value is List && value.isEmpty);

      if (isEmpty) errors[field.id] = AppStrings.fieldRequired;
    }

    return errors;
  }
}