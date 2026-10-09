import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../data/repositories/firebase_checkout_service.dart';

/// New TXID (USDT) or new receipt (Sham Cash) for an order whose payment was rejected.
Future<void> showPaymentResubmitSheet(BuildContext context, {required String orderId, required String? paymentMethod}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      builder: (_) => _ResubmitSheet(orderId: orderId, isShamCash: paymentMethod == 'sham_cash'),
    );

class _ResubmitSheet extends StatefulWidget {
  final String orderId;
  final bool isShamCash;

  const _ResubmitSheet({required this.orderId, required this.isShamCash});

  @override
  State<_ResubmitSheet> createState() => _ResubmitSheetState();
}

class _ResubmitSheetState extends State<_ResubmitSheet> {
  final _txid = TextEditingController();
  PlatformFile? _receipt;
  bool _sending = false;

  CheckoutService get _service => getIt<CheckoutService>();

  bool get _ready => widget.isShamCash ? _receipt != null : _txid.text.trim().isNotEmpty;

  @override
  void dispose() {
    _txid.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = result?.files.single;
    if (file == null || (!kIsWeb && file.path == null)) return;
    setState(() => _receipt = file);
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      final receiptUrl = widget.isShamCash
          ? await _service.uploadReceipt(orderId: '${widget.orderId}_${DateTime.now().millisecondsSinceEpoch}', file: _receipt)
          : null;
      await _service.resubmitPayment(
        orderId: widget.orderId,
        txid: widget.isShamCash ? null : _txid.text,
        receiptUrl: receiptUrl,
      );
      if (!mounted) return;
      AppSnackbar.success(context, AppStrings.paymentResent);
      Navigator.of(context).pop();
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnackbar.error(context, e.message.isEmpty ? AppStrings.somethingWentWrong : e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.spacingLg,
        right: AppConstants.spacingLg,
        top: AppConstants.spacingLg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppConstants.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.resubmitPayment, style: AppTextStyles.heading2),
          const SizedBox(height: AppConstants.spacingXs),
          Text(AppStrings.resubmitPaymentHint, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppConstants.spacingMd),
          if (widget.isShamCash)
            OutlinedButton.icon(
              onPressed: _sending ? null : _pick,
              icon: Icon(_receipt == null ? Icons.upload_file : Icons.check_circle, color: AppColors.gold),
              label: Text(_receipt?.name ?? AppStrings.pickNewReceipt, style: AppTextStyles.body),
            )
          else
            TextField(
              controller: _txid,
              enabled: !_sending,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.body.copyWith(color: AppColors.gold),
              decoration: const InputDecoration(labelText: AppStrings.txid, hintText: AppStrings.txidHint),
            ),
          const SizedBox(height: AppConstants.spacingLg),
          CustomButton(
            label: AppStrings.send,
            isLoading: _sending,
            onPressed: _ready && !_sending ? _send : null,
          ),
        ],
      ),
    );
  }
}
