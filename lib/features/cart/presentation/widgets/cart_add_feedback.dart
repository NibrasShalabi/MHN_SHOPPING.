import 'package:flutter/widgets.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubits/cart_cubit.dart';

/// One place that tells the customer why a piece wasn't added.
extension CartAddFeedback on CartAdd {
  void showRefusal(BuildContext context) {
    final message = switch (this) {
      CartAdd.added => null,
      CartAdd.full => AppStrings.cartFull,
      CartAdd.noStock => AppStrings.cartNoStock,
    };
    if (message != null) AppSnackbar.error(context, message);
  }
}
