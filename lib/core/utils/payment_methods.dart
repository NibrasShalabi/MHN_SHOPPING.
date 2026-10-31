import '../constants/app_strings.dart';

/// How a payment method is named to the customer — checkout and order details.
String paymentMethodLabel(String method) => switch (method) {
      'trc20' => 'USDT — TRC20 (Tron)',
      'bep20' => 'USDT — BEP20 (BNB Smart Chain)',
      'erc20' => 'USDT — ERC20 (Ethereum)',
      'sham_cash' => AppStrings.shamCash,
      _ => method,
    };
