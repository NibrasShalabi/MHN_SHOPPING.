import 'dart:async';

import '../../../../core/bloc/safe_cubit.dart';
import '../../data/repositories/loyalty_balance_repository.dart';

/// App-level points balance — feeds the home app-bar badge and the loyalty store.
class LoyaltyBalanceCubit extends SafeCubit<int> {
  final LoyaltyBalanceRepository _repo;
  StreamSubscription<int>? _sub;

  LoyaltyBalanceCubit(this._repo) : super(0);

  void watch() {
    _sub?.cancel();
    // A failed read keeps the last known balance rather than showing 0.
    _sub = _repo.watchBalance().listen(emit, onError: (_) {});
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
