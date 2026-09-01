import '../constants/app_strings.dart';

/// Exceptions thrown from the Data layer (Firebase, network, local cache).
/// These are caught inside Repositories and translated into a matching
/// [Failure] before reaching the Cubit/UI — the UI never sees an Exception.

class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({this.message = AppStrings.serverError, this.code});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = AppStrings.noInternetConnection});
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = AppStrings.cacheErrorLocal});
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({required this.message});
}

/// Thrown by Repositories/Cloud Functions when the current user is not
/// authorized for the requested action — e.g. a non-female user hitting
/// the Fitness section's data layer directly, or a non-admin hitting an
/// admin-only operation. This must be enforced server-side (Security
/// Rules / Cloud Functions); this exception is what the client sees back.
class PermissionException implements Exception {
  final String message;

  const PermissionException({this.message = AppStrings.noPermission});
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException({this.message = AppStrings.itemNotFound});
}

/// Thrown when a server-side idempotency/duplicate check rejects an
/// operation — e.g. rating the app twice, or replaying an order request.
class DuplicateActionException implements Exception {
  final String message;

  const DuplicateActionException({this.message = AppStrings.actionAlreadyDone});
}