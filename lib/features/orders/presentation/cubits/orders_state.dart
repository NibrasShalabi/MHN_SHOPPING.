import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/admin_message.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<OrderEntity> orders;
  final Failure? failure;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.failure,
  });

  List<OrderEntity> get activeOrders =>
      orders.where((o) => !o.status.isFinished).toList();

  List<OrderEntity> get pastOrders =>
      orders.where((o) => o.status.isFinished).toList();


  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    Failure? failure,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, orders, failure];
}