import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/health_program.dart';

enum HealthProgramStatus { initial, loading, ready, submitting, submitted, failure }

class HealthProgramState extends Equatable {
  final HealthProgramStatus status;
  final HealthProgram? program;

  /// Answers keyed by field id — the shape is defined by the admin at
  /// runtime, so there's nothing fixed to type against.
  final Map<String, dynamic> answers;

  /// Validation messages keyed by field id, filled only after a submit
  /// attempt so the form doesn't scold the user while they're still typing.
  final Map<String, String> errors;

  final Failure? failure;

  const HealthProgramState({
    this.status = HealthProgramStatus.initial,
    this.program,
    this.answers = const {},
    this.errors = const {},
    this.failure,
  });

  HealthProgramState copyWith({
    HealthProgramStatus? status,
    HealthProgram? program,
    Map<String, dynamic>? answers,
    Map<String, String>? errors,
    Failure? failure,
  }) {
    return HealthProgramState(
      status: status ?? this.status,
      program: program ?? this.program,
      answers: answers ?? this.answers,
      errors: errors ?? this.errors,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, program, answers, errors, failure];
}