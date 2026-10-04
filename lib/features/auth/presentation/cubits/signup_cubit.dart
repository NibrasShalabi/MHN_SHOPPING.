import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/signup_data.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepository _authRepository;

  SignupCubit(this._authRepository) : super(const SignupState());

  Future<void> signup(SignupData data) async {
    emit(state.copyWith(status: SignupStatus.submitting, failure: null));
    try {
      await _authRepository.signup(data);
      emit(state.copyWith(status: SignupStatus.success));
    } catch (e) {
      emit(state.copyWith(status: SignupStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }
}