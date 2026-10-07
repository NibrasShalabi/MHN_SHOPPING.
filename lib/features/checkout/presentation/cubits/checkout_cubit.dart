import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/safe_cubit.dart';
import 'dart:io';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../data/repositories/firebase_checkout_service.dart';
import 'checkout_state.dart';

class CheckoutCubit extends SafeCubit<CheckoutState> {
  final CheckoutService _service;
  PlatformFile? _receiptPlatformFile;

  CheckoutCubit(this._service) : super(const CheckoutState());

  void setReceiptFile(PlatformFile file) {
    _receiptPlatformFile = file;
    // ط¹ظ„ظ‰ ط§ظ„ظˆظٹط¨ ظ…ط§ ظپظٹ path â€” ط¨ط³ ظ†ط­طھط§ط¬ ظ†ط¹ط±ظپ ط¥ظ†ظˆ ظپظٹ ظ…ظ„ظپ ظ…ط­ط¯ط¯
    emit(state.copyWith(hasReceipt: true));
  }
  Future<void> loadAddresses() async {
    if (isClosed) return;
    emit(state.copyWith(status: CheckoutStatus.loadingAddresses));
    try {
      final addresses = await _service.getPaymentAddresses();
      if (isClosed) return;
      emit(state.copyWith(
        status: CheckoutStatus.ready,
        paymentAddresses: addresses,
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

      if (state.isShamCash && _receiptPlatformFile != null) {
        receiptUrl = await _service.uploadReceipt(
          orderId: 'tmp_${DateTime.now().millisecondsSinceEpoch}',
          file: _receiptPlatformFile!,
        );
      }

      final orderId = await _service.placeOrder(
        items: items,
        paymentMethod: state.selectedMethod,
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