import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/shipping_rates.dart';
import '../../../../core/config/features.dart';

enum CheckoutStatus { initial, loadingAddresses, ready, submitting, success, failure }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final Map<String, String> paymentAddresses;
  final ShippingRates shippingRates;
  final String? governorate;
  final String selectedMethod;
  final bool hasReceipt;
  final String? orderId;
  final Failure? failure;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.paymentAddresses = const {},
    this.shippingRates = const ShippingRates(),
    this.governorate,
    this.selectedMethod = 'trc20',
    this.hasReceipt = false,
    this.orderId,
    this.failure,
  });

  String get selectedAddress => paymentAddresses[selectedMethod] ?? '';
  bool get hasPaymentMethods => paymentAddresses.isNotEmpty;
  bool get isShamCash => selectedMethod == 'sham_cash';
  /// Sham Cash proves payment with a receipt photo only while uploads are on;
  /// otherwise every method uses a transaction number (checked on the page).
  bool get needsReceipt => isShamCash && Features.receiptUploads;

  bool get canSubmit =>
      selectedAddress.isNotEmpty && status == CheckoutStatus.ready && (needsReceipt ? hasReceipt : true);

  CheckoutState copyWith({
    CheckoutStatus? status,
    Map<String, String>? paymentAddresses,
    ShippingRates? shippingRates,
    String? governorate,
    String? selectedMethod,
    bool? hasReceipt,
    bool clearReceipt = false,
    String? orderId,
    Failure? failure,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      paymentAddresses: paymentAddresses ?? this.paymentAddresses,
      shippingRates: shippingRates ?? this.shippingRates,
      governorate: governorate ?? this.governorate,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      hasReceipt: clearReceipt ? false : (hasReceipt ?? this.hasReceipt),
      orderId: orderId ?? this.orderId,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status, paymentAddresses, shippingRates, governorate, selectedMethod, hasReceipt, orderId, failure,
  ];
}