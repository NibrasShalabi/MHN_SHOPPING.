import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';

enum SuggestProductStatus { initial, submitting, success, failure }

class SuggestProductState extends Equatable {
  final SuggestProductStatus status;
  final Failure? failure;

  const SuggestProductState({
    this.status = SuggestProductStatus.initial,
    this.failure,
  });

  SuggestProductState copyWith({SuggestProductStatus? status, Failure? failure}) {
    return SuggestProductState(
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}