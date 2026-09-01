import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

enum SignupStatus { initial, submitting, success, failure }

class SignupState extends Equatable {
  final SignupStatus status;
  final Failure? failure;

  const SignupState({this.status = SignupStatus.initial, this.failure});

  SignupState copyWith({SignupStatus? status, Failure? failure}) {
    return SignupState(
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}