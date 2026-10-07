import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends SafeCubit<OrdersState> {
  final OrdersRepository _ordersRepository;

  OrdersCubit(this._ordersRepository) : super(const OrdersState());

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: OrdersStatus.loading, failure: null));
    try {
      final orders = await _ordersRepository.getOrders();
      if (isClosed) return;
      emit(state.copyWith(status: OrdersStatus.success, orders: orders));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: OrdersStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }
}