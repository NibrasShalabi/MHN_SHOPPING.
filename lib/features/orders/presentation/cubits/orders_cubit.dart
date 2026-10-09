import 'dart:async';

import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/orders_repository.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_state.dart';

/// App-level, live: one listener for the session instead of a re-fetch per visit.
class OrdersCubit extends SafeCubit<OrdersState> {
  final OrdersRepository _ordersRepository;
  StreamSubscription<List<OrderEntity>>? _sub;

  OrdersCubit(this._ordersRepository) : super(const OrdersState());

  /// Starts listening; calling it again (pull-to-refresh) re-subscribes.
  Future<void> load() async {
    await _sub?.cancel();
    if (state.orders.isEmpty) emit(state.copyWith(status: OrdersStatus.loading, failure: null));
    _sub = _ordersRepository.watchOrders().listen(
      (orders) => emit(state.copyWith(status: OrdersStatus.success, orders: orders)),
      onError: (Object e) => emit(state.copyWith(status: OrdersStatus.failure, failure: mapExceptionToFailure(e))),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
