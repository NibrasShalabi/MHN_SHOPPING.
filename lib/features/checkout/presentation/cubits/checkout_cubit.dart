import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/bloc/safe_cubit.dart';
import 'dart:io';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../data/repositories/firebase_checkout_service.dart';
import '../../domain/entities/shipping_rates.dart';
import 'checkout_state.dart';

class CheckoutCubit extends SafeCubit<CheckoutState> {
  final CheckoutService _service;
  PlatformFile? _receiptPlatformFile;

  CheckoutCubit(this._service) : super(const CheckoutState());

  void setReceiptFile(PlatformFile file) {
    _receiptPlatformFile = file;
    emit(state.copyWith(hasReceipt: true));
  }
  Future<void> loadAddresses() async {
    if (isClosed) return;
    emit(state.copyWith(status: CheckoutStatus.loadingAddresses));
    try {
      // Future.wait rethrows the first ServerException as-is.
      final results = await Future.wait<Object?>([
        _service.getPaymentAddresses(),
        _service.getShippingRates(),
        _service.getGovernorate(),
      ]);
      final addresses = results[0] as Map<String, String>;
      final rates = results[1] as ShippingRates;
      final governorate = results[2] as String?;
      if (isClosed) return;
      emit(state.copyWith(
        status: CheckoutStatus.ready,
        paymentAddresses: addresses,
        // The default may have been switched off by the admin.
        selectedMethod: addresses.containsKey(state.selectedMethod) || addresses.isEmpty
            ? state.selectedMethod
            : addresses.keys.first,
        shippingRates: rates,
        governorate: governorate,
      ));
    } on ServerException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        failure: ServerFailure(e.message),
      ));
    }
  }

  void selectMethod(String method) {
    emit(state.copyWith(
      selectedMethod: method,
      clearReceipt: true,
    ));
  }
  Future<void> submit({required List<CartItem> items, String? txid}) async {
    if (isClosed) return;
    emit(state.copyWith(status: CheckoutStatus.submitting));
    try {
      String? receiptUrl;
      final pointsOnly = items.every((i) => i.isPoints);

      if (!pointsOnly && state.isShamCash && _receiptPlatformFile != null) {
        receiptUrl = await _service.uploadReceipt(
          orderId: 'tmp_${DateTime.now().millisecondsSinceEpoch}',
          file: _receiptPlatformFile!,
        );
      }

      final orderId = await _service.placeOrder(
        items: items,
        paymentMethod: pointsOnly ? 'points' : state.selectedMethod,
        txid: txid,
        receiptUrl: receiptUrl,
      );

      if (isClosed) return;
      emit(state.copyWith(status: CheckoutStatus.success, orderId: orderId));
    } on ServerException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        failure: ServerFailure(e.message),
      ));
    }
  }
}