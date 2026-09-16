import '../../domain/entities/currency_rate.dart';

/// Repository for currency conversion.
abstract class CurrencyConverterRepository {
  /// Convert amount from USD to target currency using provided rate.
  /// [amountInUsd] = amount to convert
  /// [targetCurrency] = target currency
  /// [rate] = user-provided exchange rate (how much 1 USD = X in target)
  double convertUsdTo({
    required double amountInUsd,
    required CurrencyType targetCurrency,
    required double rate,
  });

  /// Convert amount back from target currency to USD.
  double convertBackToUsd({
    required double amountInTarget,
    required CurrencyType targetCurrency,
    required double rate,
  });

  /// Format currency amount with symbol.
  String formatCurrency({
    required double amount,
    required CurrencyType currency,
    int decimalPlaces = 2,
  });

  /// Get exchange rate suggestions based on real-time data.
  /// In logic phase, this could fetch from an API.
  Future<double> getSuggestedRate(CurrencyType targetCurrency);

  /// Validate if a rate is reasonable (basic sanity check).
  bool isReasonableRate({
    required double rate,
    required CurrencyType targetCurrency,
  });
}

/// Fake implementation for UI phase.
class FakeCurrencyConverterRepository implements CurrencyConverterRepository {
  /// Typical rates (for UI phase demo).
  /// In real implementation, these come from an API or Firebase.
  static const Map<CurrencyType, double> _suggestedRates = {
    CurrencyType.usd: 1.0,
    CurrencyType.syd: 12850.0, // ~1 USD = 12,850 Syrian Pounds (realistic)
    CurrencyType.sar: 3.75, // ~1 USD = 3.75 SAR
  };

  /// Reasonable rate ranges for validation.
  static const Map<CurrencyType, (double, double)> _reasonableRanges = {
    CurrencyType.usd: (0.99, 1.01),
    CurrencyType.syd: (10000, 20000), // Wide range due to market volatility
    CurrencyType.sar: (3.0, 4.5),
  };

  @override
  double convertUsdTo({
    required double amountInUsd,
    required CurrencyType targetCurrency,
    required double rate,
  }) {
    if (targetCurrency == CurrencyType.usd) return amountInUsd;
    return amountInUsd * rate;
  }

  @override
  double convertBackToUsd({
    required double amountInTarget,
    required CurrencyType targetCurrency,
    required double rate,
  }) {
    if (targetCurrency == CurrencyType.usd) return amountInTarget;
    if (rate == 0) return 0;
    return amountInTarget / rate;
  }

  @override
  String formatCurrency({
    required double amount,
    required CurrencyType currency,
    int decimalPlaces = 2,
  }) {
    final symbol = currency.symbol;
    final formatted = amount.toStringAsFixed(decimalPlaces);

    // Arabic currencies are typically RTL (symbol on right)
    if (currency == CurrencyType.syd || currency == CurrencyType.sar) {
      return '$formatted $symbol';
    }
    // USD symbol on left
    return '$symbol $formatted';
  }

  @override
  Future<double> getSuggestedRate(CurrencyType targetCurrency) async {
    // Simulate API call to fetch real-time rate
    await Future.delayed(const Duration(milliseconds: 500));

    final baseRate = _suggestedRates[targetCurrency] ?? 1.0;

    // Add slight random variation to simulate real-time movement
    // (±2% variation for demo purposes)
    final variation = 0.98 + (DateTime.now().millisecond / 5000);
    return baseRate * variation;
  }

  @override
  bool isReasonableRate({
    required double rate,
    required CurrencyType targetCurrency,
  }) {
    if (rate <= 0) return false;

    final range = _reasonableRanges[targetCurrency];
    if (range == null) return true; // Unknown currency, allow

    return rate >= range.$1 && rate <= range.$2;
  }

  /// Helper: Format with commas for thousands (for SYD which are large numbers)
  String formatWithSeparators({
    required double amount,
    required CurrencyType currency,
  }) {
    final formatted = amount.toStringAsFixed(0);
    final parts = formatted.split('.');
    final wholePart = parts[0];

    // Add thousands separator
    final withSeparator = wholePart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );

    final symbol = currency.symbol;

    if (currency == CurrencyType.syd || currency == CurrencyType.sar) {
      return '$withSeparator $symbol';
    }
    return '$symbol $withSeparator';
  }
}