import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../data/repository/fitness_repository.dart';

/// Opens WhatsApp with the specialist the admin set, optionally with a
/// first line about a product — consult-only items are ordered this way.
abstract final class SpecialistContact {
  static Future<void> open(BuildContext context, {String? about}) async {
    try {
      final number = await GetIt.instance<FitnessRepository>().getSpecialistWhatsapp();
      if (number.isEmpty) {
        if (context.mounted) AppSnackbar.error(context, AppStrings.specialistUnavailable);
        return;
      }
      final uri = Uri.https('wa.me', '/$number', {if (about != null) 'text': AppStrings.consultAbout(about)});
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) AppSnackbar.error(context, AppStrings.somethingWentWrong);
    } catch (_) {
      if (context.mounted) AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }
}
