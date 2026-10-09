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
  final double total;
  final DateTime? expectedDelivery;
  final String? statusNote;
  final String? paymentMethod;   // 'trc20' | 'bep20' | 'erc20' | 'sham_cash' | 'cod'
  final String? txid;
  final String? receiptUrl;
  final String? paymentStatus;   // 'pending' | 'verified' | 'rejected'
  final String? paymentRejectReason;

  const OrderEntity({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.lines,
    required this.total,
    this.expectedDelivery,
    this.statusNote,
    this.paymentMethod,
    this.txid,
    this.receiptUrl,
    this.paymentStatus,
    this.paymentRejectReason,
  });

  /// Money order whose payment the admin rejected — the customer can send a new one.
  bool get isPaymentRejected => paymentStatus == 'rejected' && status != OrderStatus.cancelled;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);
  Duration get elapsed => DateTime.now().difference(createdAt);

  @override
  List<Object?> get props => [
    id, createdAt, status, lines, total,
    expectedDelivery, statusNote,
    paymentMethod, txid, receiptUrl, paymentStatus, paymentRejectReason,
  ];
}