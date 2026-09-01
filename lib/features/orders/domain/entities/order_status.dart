import '../../../../core/constants/app_strings.dart';

/// Order lifecycle. The order is the sequence the user is walked through
/// in the timeline; cancelled/delayed sit outside it as interruptions.
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  delayed,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => AppStrings.orderStatusPending,
    OrderStatus.confirmed => AppStrings.orderStatusConfirmed,
    OrderStatus.preparing => AppStrings.orderStatusPreparing,
    OrderStatus.outForDelivery => AppStrings.orderStatusOutForDelivery,
    OrderStatus.delivered => AppStrings.orderStatusDelivered,
    OrderStatus.delayed => AppStrings.orderStatusDelayed,
    OrderStatus.cancelled => AppStrings.orderStatusCancelled,
  };

  /// Steps shown in the progress timeline, in order.
  static const List<OrderStatus> timeline = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  bool get isInterrupted =>
      this == OrderStatus.cancelled || this == OrderStatus.delayed;

  bool get isFinished =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}