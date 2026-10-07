import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';

enum CheckoutStatus { initial, loadingAddresses, ready, submitting, success, failure }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final Map<String, String> paymentAddresses;
  final String selectedMethod;
  final bool hasReceipt;
  final String? orderId;
  final Failure? failure;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.paymentAddresses = const {},
    this.selectedMethod = 'trc20',
    this.hasReceipt = false,
    this.orderId,
    this.failure,
  });

  String get selectedAddress => paymentAddresses[selectedMethod] ?? '';
  bool get isShamCash => selectedMethod == 'sham_cash';
  bool get canSubmit =>
      status == CheckoutStatus.ready && (isShamCash ? hasReceipt : true);

  CheckoutState copyWith({
    CheckoutStatus? status,
    Map<String, String>? paymentAddresses,
    String? selectedMethod,
    bool? hasReceipt,
    bool clearReceipt = false,
    String? orderId,
    Failure? failure,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      paymentAddresses: paymentAddresses ?? this.paymentAddresses,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      hasReceipt: clearReceipt ? false : (hasReceipt ?? this.hasReceipt),
      orderId: orderId ?? this.orderId,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status, paymentAddresses, selectedMethod, hasReceipt, orderId, failure,
  ];
}