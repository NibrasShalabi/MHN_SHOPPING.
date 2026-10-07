import '../../../../core/bloc/safe_cubit.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends SafeCubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(const LoginState());

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: LoginStatus.submitting, failure: null));
    try {
      await _authRepository.login(email: email, password: password);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, failure: mapExceptionToFailure(e)));
    }
  }
}