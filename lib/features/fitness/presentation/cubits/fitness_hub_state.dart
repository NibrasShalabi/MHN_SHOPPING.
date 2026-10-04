import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/health_program.dart';

enum FitnessHubStatus { initial, loading, success, failure }

class FitnessHubState extends Equatable {
  final FitnessHubStatus status;
  final List<HealthProgram> programs;
  final Failure? failure;

  const FitnessHubState({
    this.status = FitnessHubStatus.initial,
    this.programs = const [],
    this.failure,
  });

  FitnessHubState copyWith({
    FitnessHubStatus? status,
    List<HealthProgram>? programs,
    Failure? failure,
  }) {
    return FitnessHubState(
      status: status ?? this.status,
      programs: programs ?? this.programs,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, programs, failure];
}