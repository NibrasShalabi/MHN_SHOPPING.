import 'package:equatable/equatable.dart';

/// Promotion entity for the "شرار ونار" (Deals) section.
/// Products added to this promotion get a temporary discount for a fixed duration.
class Promotion extends Equatable {
  final String id;

  /// The product being promoted.
  final String productId;

  /// Discount percentage (0-100).
  final double discountPercentage;

  /// When the promotion started.
  final DateTime startTime;

  /// When the promotion ends. After this, product returns to normal.
  final DateTime endTime;

  /// Whether this promotion is currently active.
  final bool isActive;

  const Promotion({
    required this.id,
    required this.productId,
    required this.discountPercentage,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  /// Check if promotion has expired.
  bool get isExpired => DateTime.now().isAfter(endTime);

  /// Remaining duration until promotion ends.
  Duration get remainingDuration => endTime.difference(DateTime.now());

  /// Calculate discounted price from original price.
  double getDiscountedPrice(double originalPrice) {
    return originalPrice * (1 - (discountPercentage / 100));
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    discountPercentage,
    startTime,
    endTime,
    isActive,
  ];
}