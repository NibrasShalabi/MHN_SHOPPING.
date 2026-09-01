import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

enum ForgotPasswordStatus { initial, submitting, success, failure }

class ForgotPasswordState extends Equatable {
  final ForgotPasswordStatus status;
  final Failure? failure;

  const ForgotPasswordState({this.status = ForgotPasswordStatus.initial, this.failure});

  ForgotPasswordState copyWith({ForgotPasswordStatus? status, Failure? failure}) {
    return ForgotPasswordState(
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}