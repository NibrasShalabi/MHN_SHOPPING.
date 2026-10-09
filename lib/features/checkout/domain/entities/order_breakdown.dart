import 'package:equatable/equatable.dart';

import 'shipping_rates.dart';

/// What the customer pays: items + supply shipping (per piece) + delivery (per governorate).
///
/// Built from the cart for display, and again inside the checkout
/// transaction from the product docs — the stored order uses the latter.
class OrderBreakdown extends Equatable {
  final double itemsTotal;
  final double supplyShipping;
  final double deliveryFee;

  const OrderBreakdown({required this.itemsTotal, required this.supplyShipping, required this.deliveryFee});

  factory OrderBreakdown.compute({
    required Iterable<({double unitPrice, double shippingPerUnit, int quantity})> lines,
    required ShippingRates rates,
    required String? governorate,
  }) {
    var items = 0.0;
    var supply = 0.0;
    for (final l in lines) {
      items += l.unitPrice * l.quantity;
      supply += l.shippingPerUnit * l.quantity;
    }
    return OrderBreakdown(
      itemsTotal: items,
      supplyShipping: supply,
      deliveryFee: items > 0 ? rates.deliveryFor(governorate, items) : 0,
    );
  }

  double get total => itemsTotal + supplyShipping + deliveryFee;

  @override
  List<Object?> get props => [itemsTotal, supplyShipping, deliveryFee];
}
