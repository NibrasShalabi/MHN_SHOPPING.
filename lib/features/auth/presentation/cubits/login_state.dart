import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final Failure? failure;

  const LoginState({this.status = LoginStatus.initial, this.failure});

  LoginState copyWith({LoginStatus? status, Failure? failure}) {
    return LoginState(
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}