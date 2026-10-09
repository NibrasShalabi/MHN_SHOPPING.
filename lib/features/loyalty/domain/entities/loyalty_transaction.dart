import 'package:equatable/equatable.dart';

/// One line in the customer's points history — earned (+) or spent/refunded (−/+).
class LoyaltyTransaction extends Equatable {
  final String id;
  final int points;
  final String reason;
  final String? orderId;
  final DateTime createdAt;

  const LoyaltyTransaction({
    required this.id,
    required this.points,
    required this.reason,
    this.orderId,
    required this.createdAt,
  });

  bool get isGain => points >= 0;

  @override
  List<Object?> get props => [id, points, reason, orderId, createdAt];
}
