import 'package:equatable/equatable.dart';

/// Currency rates for conversion.
/// Stores exchange rates from USD to other currencies.
enum CurrencyType { usd, syd, sar }

extension CurrencyTypeX on CurrencyType {
  String get symbol => switch (this) {
    CurrencyType.usd => '\$',
    CurrencyType.syd => 'ل.س',
    CurrencyType.sar => '﷼',
  };

  String get name => switch (this) {
    CurrencyType.usd => 'USD',
    CurrencyType.syd => 'SYD',
    CurrencyType.sar => 'SAR',
  };
}

class CurrencyRate extends Equatable {
  /// Base currency (always USD in this case).
  final CurrencyType from;

  /// Target currency.
  final CurrencyType to;

  /// Exchange rate (how much 1 USD = X in target currency).
  /// User enters this value when converting.
  final double rate;

  const CurrencyRate({
    required this.from,
    required this.to,
    required this.rate,
  });

  /// Convert amount from USD to target currency.
  double convert(double amountInUsd) {
    return amountInUsd * rate;
  }

  /// Convert back from target currency to USD.
  double convertBack(double amountInTarget) {
    return amountInTarget / rate;
  }

  @override
  List<Object?> get props => [from, to, rate];
}