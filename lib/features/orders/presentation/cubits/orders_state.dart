import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_message.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<OrderEntity> orders;
  final List<AdminMessage> messages;
  final Failure? failure;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.messages = const [],
    this.failure,
  });

  List<OrderEntity> get activeOrders =>
      orders.where((o) => !o.status.isFinished).toList();

  List<OrderEntity> get pastOrders =>
      orders.where((o) => o.status.isFinished).toList();

  int get messageCount => messages.length;

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    List<AdminMessage>? messages,
    Failure? failure,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      messages: messages ?? this.messages,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, orders, messages, failure];
}