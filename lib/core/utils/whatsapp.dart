import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_strings.dart';
import '../widgets/app_snackbar.dart';

/// Opens a WhatsApp chat with [number] (digits with country code),
/// optionally pre-filled with [text]. Shows an error when it can't.
abstract final class WhatsApp {
  static Future<void> open(BuildContext context, String number, {String? text}) async {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      AppSnackbar.error(context, AppStrings.contactUnavailable);
      return;
    }
    final uri = Uri.https('wa.me', '/$digits', {'text': ?text});
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }

  static Future<void> call(BuildContext context, String number) async {
    if (!await launchUrl(Uri(scheme: 'tel', path: '+${number.replaceAll(RegExp(r'[^0-9]'), '')}')) && context.mounted) {
      AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }

  static Future<void> openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if ((uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) && context.mounted) {
      AppSnackbar.error(context, AppStrings.somethingWentWrong);
    }
  }
}
