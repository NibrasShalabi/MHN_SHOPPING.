import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bar_bottom_border.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom/custom_button.dart';
import '../../../../core/widgets/surface_card.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;
  const OrderConfirmationPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        elevation: 0,
        bottom: const AppBarBottomBorder(),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(AppStrings.orderConfirmed, style: AppTextStyles.heading2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppConstants.spacingLg),
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.gold,
              size: 72,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              AppStrings.orderPlacedSuccessfully,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXl),
            SurfaceCard(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.orderNumber,
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary)),
                  Row(
                    children: [
                      Text(orderId,
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: AppConstants.spacingXs),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: orderId));
                          AppSnackbar.info(context, AppStrings.copied);
                        },
                        child: const Icon(Icons.copy_outlined,
                            color: AppColors.textDisabled,
                            size: AppConstants.iconSm),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            SurfaceCard(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Text(
                AppStrings.orderConfirmationNote,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            CustomButton(
              label: AppStrings.trackOrder,
              icon: Icons.local_shipping_outlined,
              width: double.infinity,
              onPressed: () => context.go(RouteNames.orderTracking),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            CustomButton(
              label: AppStrings.continueShopping,
              icon: Icons.storefront_outlined,
              width: double.infinity,
              isOutlined: true,
              onPressed: () => context.go(RouteNames.home),
            ),
          ],
        ),
      ),
    );
  }
}