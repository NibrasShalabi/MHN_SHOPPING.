import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/orders_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository _ordersRepository;

  OrdersCubit(this._ordersRepository) : super(const OrdersState());

  Future<void> load() async {
    emit(state.copyWith(status: OrdersStatus.loading, failure: null));
    try {
      final orders = await _ordersRepository.getOrders();
      final messages = await _ordersRepository.getMessages();
      emit(state.copyWith(
        status: OrdersStatus.success,
        orders: orders,
        messages: messages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrdersStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }

  /// Messages are one-shot: acknowledging one removes it from the inbox.
  Future<void> dismissMessage(String messageId) async {
    try {
      await _ordersRepository.dismissMessage(messageId);
      final messages = await _ordersRepository.getMessages();
      emit(state.copyWith(messages: messages));
    } catch (e) {
      emit(state.copyWith(failure: mapExceptionToFailure(e)));
    }
  }
}