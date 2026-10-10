import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/account_repository.dart';
import '../../domain/entities/user_profile.dart';
import 'account_state.dart';

/// Actions return the failure (or null on success) so the page can show a
/// one-off message without keeping it in the state.
class AccountCubit extends SafeCubit<AccountState> {
  final AccountRepository _repository;

  AccountCubit(this._repository) : super(const AccountState());

  Future<void> load({bool refresh = false}) async {
    emit(state.copyWith(status: AccountStatus.loading));
    try {
      emit(state.copyWith(status: AccountStatus.ready, profile: await _repository.profile(refresh: refresh)));
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.error, failure: mapExceptionToFailure(e)));
    }
  }

  Future<Failure?> save(UserProfile p) => _run(() async {
        final saved = await _repository.updateProfile(p);
        emit(state.copyWith(profile: saved));
      });

  Future<Failure?> changePassword(String current, String next) =>
      _run(() => _repository.changePassword(current: current, next: next));

  Future<Failure?> signOut() => _run(_repository.signOut);

  Future<Failure?> _run(Future<void> Function() action) async {
    if (state.busy) return null;
    emit(state.copyWith(busy: true));
    try {
      await action();
      emit(state.copyWith(busy: false));
      return null;
    } catch (e) {
      emit(state.copyWith(busy: false));
      return mapExceptionToFailure(e);
    }
  }
}
