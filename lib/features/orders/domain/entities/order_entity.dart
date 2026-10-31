import 'package:equatable/equatable.dart';

import 'order_status.dart';

class OrderLine extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? size;
  final String? colorName;

  /// Loyalty gift — [price] is in points.
  final bool isPoints;

  const OrderLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.size,
    this.colorName,
    this.isPoints = false,
  });

  double get lineTotal => price * quantity;

  @override
  List<Object?> get props => [productId, name, quantity, price, imageUrl, size, colorName, isPoints];
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

  /// The breakdown saved at checkout; [total] = items + supply shipping + delivery.
  final double itemsTotal;
  final double supplyShipping;
  final double deliveryFee;
  final int pointsTotal;
  final String? governorate;
  final String? area;

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
    this.itemsTotal = 0,
    this.supplyShipping = 0,
    this.deliveryFee = 0,
    this.pointsTotal = 0,
    this.governorate,
    this.area,
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
    itemsTotal, supplyShipping, deliveryFee, pointsTotal, governorate, area,
  ];
}