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
    // احذف من الـ UI فوراً
    final updatedMessages = state.messages
        .where((m) => m.id != messageId)
        .toList();
    emit(state.copyWith(messages: updatedMessages));

    // اعمل الـ update بالخلفية
    try {
      await _ordersRepository.dismissMessage(messageId);
    } catch (_) {
      // لو فشل — ما في مشكلة، الـ UI محدّث
    }
  }
}