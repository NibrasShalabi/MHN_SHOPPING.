import '../../../../core/constants/app_strings.dart';
import '../../../home/domain/entities/product.dart';

/// One place that formats a cart amount in its own unit — `$ 12.50` or `40 نقطة`.
String formatCartAmount(double amount, PricingKind pricing) => pricing == PricingKind.points
    ? '${amount.toStringAsFixed(0)} ${AppStrings.pointsUnit}'
    : '\$${amount.toStringAsFixed(2)}';
