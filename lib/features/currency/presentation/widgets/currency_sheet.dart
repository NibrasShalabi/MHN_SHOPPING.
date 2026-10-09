import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'currency_form.dart';

/// The converter as a bottom sheet — from checkout and from a product page.
Future<void> showCurrencySheet(BuildContext context, {double? amount}) => showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceWine,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppConstants.spacingMd,
          AppConstants.spacingSm,
          AppConstants.spacingMd,
          AppConstants.spacingMd + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppConstants.spacingXl,
                height: AppConstants.borderThin * 3,
                margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
              ),
            ),
            Text(AppStrings.currencyConverter, style: AppTextStyles.heading2),
            const SizedBox(height: AppConstants.spacingMd),
            CurrencyForm(initialAmount: amount),
            const SizedBox(height: AppConstants.spacingMd),
          ],
        ),
      ),
    );

/// App-bar button that opens [showCurrencySheet].
class CurrencySheetButton extends StatelessWidget {
  final double? amount;

  const CurrencySheetButton({super.key, this.amount});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.currency_exchange, color: AppColors.iconPrimary),
        tooltip: AppStrings.currencyConverter,
        onPressed: () => showCurrencySheet(context, amount: amount),
      );
}
