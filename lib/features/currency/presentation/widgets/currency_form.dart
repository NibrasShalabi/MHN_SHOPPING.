import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';
import '../../../deals/data/repositories/currency_converter_repository.dart';
import '../../../deals/domain/entities/currency_rate.dart';

/// قابل للاستخدام في CurrencyPage و CheckoutPage popup.
class CurrencyForm extends StatefulWidget {
  final double? initialAmount;
  const CurrencyForm({super.key, this.initialAmount});

  @override
  State<CurrencyForm> createState() => _CurrencyFormState();
}

class _CurrencyFormState extends State<CurrencyForm> {
  final _repository = FakeCurrencyConverterRepository();
  late final TextEditingController _amountController;
  final _rateController = TextEditingController();
  CurrencyType _selected = CurrencyType.syd;
  double _converted = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _convert() {
    final amount = double.tryParse(_amountController.text);
    final rate = double.tryParse(_rateController.text);
    if (amount == null || rate == null || rate <= 0) {
      setState(() => _converted = 0);
      return;
    }
    setState(() {
      _converted = _repository.convertUsdTo(
        amountInUsd: amount,
        targetCurrency: _selected,
        rate: rate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CurrencyField(
          controller: _amountController,
          label: AppStrings.amountUsd,
          hint: '0.00',
          onChanged: (_) => _convert(),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingXs,
          ),
          child: DropdownButtonFormField<CurrencyType>(
            value: _selected,
            dropdownColor: AppColors.surfaceElevated,
            decoration: const InputDecoration(
              labelText: AppStrings.currencyTarget,
              border: InputBorder.none,
            ),
            style: AppTextStyles.body,
            items: CurrencyType.values
                .where((c) => c != CurrencyType.usd)
                .map((c) => DropdownMenuItem(
              value: c,
              child: Text('${c.name} (${c.symbol})', style: AppTextStyles.body),
            ))
                .toList(),
            onChanged: (c) {
              if (c == null) return;
              setState(() {
                _selected = c;
                _converted = 0;
              });
              _convert();
            },
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _CurrencyField(
          controller: _rateController,
          label: AppStrings.exchangeRate,
          hint: AppStrings.exchangeRateHint,
          onChanged: (_) => _convert(),
        ),
        if (_converted > 0) ...[
          const SizedBox(height: AppConstants.spacingLg),
          SurfaceCard(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.convertedAmount,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                Text(
                  _repository.formatCurrency(amount: _converted, currency: _selected),
                  style: AppTextStyles.heading2.copyWith(color: AppColors.gold),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _CurrencyField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingXs,
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTextStyles.body,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
          border: InputBorder.none,
        ),
      ),
    );
  }
}