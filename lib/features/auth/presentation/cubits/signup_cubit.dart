import '../../../../core/bloc/safe_cubit.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/signup_data.dart';
import 'signup_state.dart';

class SignupCubit extends SafeCubit<SignupState> {
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