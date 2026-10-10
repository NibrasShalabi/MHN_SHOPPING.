import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/whatsapp.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../data/repository/fitness_repository.dart';

/// WhatsApp with the specialist the admin set, optionally about a product —
/// consult-only items are ordered this way.
abstract final class SpecialistContact {
  static Future<void> open(BuildContext context, {String? about}) async {
    try {
      final number = await GetIt.instance<FitnessRepository>().getSpecialistWhatsapp();
      if (!context.mounted) return;
      await WhatsApp.open(context, number, text: about == null ? null : AppStrings.consultAbout(about));
    } catch (_) {
      if (context.mounted) AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }
}
