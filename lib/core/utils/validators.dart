import '../constants/app_strings.dart';

/// Shared, synchronous field validators — used directly in pages since
/// CustomTextField has no built-in Form validation (it's a plain
/// TextField, not a TextFormField). Each function returns an error
/// message (String) or null when the value is valid.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
  static final RegExp _phoneRegex = RegExp(r'^(\+963|0)?9\d{8}$');

  static String? required(String? value, {String message = AppStrings.fieldRequired}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (!_emailRegex.hasMatch(value!.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (value!.length < minLength) return AppStrings.passwordTooShort.replaceFirst('{min}', '$minLength');
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (value != original) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static String? phone(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (!_phoneRegex.hasMatch(value!.trim())) return AppStrings.invalidPhone;
    return null;
  }

  /// Optional field — only validated if the user actually entered something.
  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return phone(value);
  }

  static const int maxLinkLength = 500;
  static const int maxProductNameLength = 100;

  /// Control characters and newlines — used to smuggle payloads past
  /// naive parsers and to break log output. Checked by code unit rather
  /// than a regex so the escaping stays unambiguous.
  static bool _hasControlChars(String value) {
    for (final unit in value.codeUnits) {
      if (unit < 0x20 || unit == 0x7F) return true;
    }
    return false;
  }

  /// Validates a user-submitted product link.
  ///
  /// https only, on purpose. `javascript:`, `data:` and `file:` are the
  /// schemes that turn a stored string into an attack when someone later
  /// clicks it from the admin dashboard, and plain `http` can be
  /// intercepted — so the allow-list is a single scheme rather than a
  /// block-list of bad ones.
  ///
  /// NOTE(logic-phase): this must be repeated in the Cloud Function that
  /// writes the suggestion. Client-side validation only shapes the input
  /// for honest users; anyone hitting the API directly bypasses it.
  static String? productLink(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;

    final raw = value!.trim();
    if (raw.length > maxLinkLength) return AppStrings.linkTooLong;

    if (_hasControlChars(raw)) return AppStrings.invalidLink;

    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.isAbsolute) return AppStrings.invalidLink;
    if (uri.scheme.toLowerCase() != 'https') return AppStrings.linkMustBeHttps;
    if (uri.host.isEmpty || !uri.host.contains('.')) return AppStrings.invalidLink;

    return null;
  }

  static String? productName(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (value!.trim().length > maxProductNameLength) return AppStrings.nameTooLong;
    if (_hasControlChars(value)) return AppStrings.fieldRequired;
    return null;
  }
}