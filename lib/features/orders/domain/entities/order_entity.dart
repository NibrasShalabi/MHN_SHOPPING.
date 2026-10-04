import 'package:equatable/equatable.dart';

import 'order_status.dart';

class OrderLine extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  const OrderLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => price * quantity;

  @override
  List<Object?> get props => [productId, name, quantity, price];
}

class OrderEntity extends Equatable {
  final String id;
  final DateTime createdAt;
  final OrderStatus status;
  final List<OrderLine> lines;

  /// Computed server-side at creation — the client only displays it.
  final double total;

  final DateTime? expectedDelivery;

  /// Set by the admin when the order is delayed or cancelled.
  final String? statusNote;

  const OrderEntity({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.lines,
    required this.total,
    this.expectedDelivery,
    this.statusNote,
  });

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  /// How long the order has been open — "مدة الطلب" in the requirements.
  Duration get elapsed => DateTime.now().difference(createdAt);

  @override
  List<Object?> get props =>
      [id, createdAt, status, lines, total, expectedDelivery, statusNote];
}