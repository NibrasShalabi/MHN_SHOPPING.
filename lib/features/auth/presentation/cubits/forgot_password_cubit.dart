import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/auth_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordCubit(this._authRepository) : super(const ForgotPasswordState());

  Future<void> sendResetEmail(String email) async {
    emit(state.copyWith(status: ForgotPasswordStatus.submitting, failure: null));
    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ForgotPasswordStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }
}