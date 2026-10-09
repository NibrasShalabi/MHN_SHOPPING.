import 'package:equatable/equatable.dart';

/// Delivery from the shop to the customer, per governorate — `config/shipping`,
/// edited from the admin's Shipping section. Keep [deliveryFor] in step with
/// the admin's copy: it re-checks every order with the same formula.
class ShippingRates extends Equatable {
  final Map<String, double> fees;
  final bool freeEnabled;
  final double freeAbove;

  const ShippingRates({this.fees = const {}, this.freeEnabled = false, this.freeAbove = 0});

  double deliveryFor(String? governorate, double itemsTotal) {
    if (freeEnabled && freeAbove > 0 && itemsTotal >= freeAbove) return 0;
    return fees[governorate] ?? 0;
  }

  factory ShippingRates.fromMap(Map<String, dynamic> d) => ShippingRates(
        fees: {
          for (final e in (d['fees'] as Map? ?? const {}).entries) e.key as String: (e.value as num).toDouble(),
        },
        freeEnabled: d['freeEnabled'] as bool? ?? false,
        freeAbove: (d['freeAbove'] as num? ?? 0).toDouble(),
      );

  @override
  List<Object?> get props => [fees, freeEnabled, freeAbove];
}
