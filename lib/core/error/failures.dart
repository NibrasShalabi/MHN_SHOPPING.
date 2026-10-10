import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/app_strings.dart';
import 'exceptions.dart';

/// Failures are what Repositories return to the domain/presentation layer
/// (instead of throwing). Every Cubit state that can fail should hold a
/// [Failure], never a raw Exception or a String — this keeps error
/// handling consistent across every feature.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = AppStrings.serverErrorRetry]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = AppStrings.checkYourConnection]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = AppStrings.cacheError]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// User tried to access something they're not authorized for.
/// Primary real-world case in this project: a non-female user reaching
/// the Fitness section's data (must never rely on the Route Guard alone —
/// this is the failure the Repository returns when the backend itself
/// rejects the request).
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = AppStrings.noPermission]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = AppStrings.itemNotFound]);
}

/// Server rejected the action because it already happened — app rating
/// submitted twice, an order request replayed, etc.
class DuplicateActionFailure extends Failure {
  const DuplicateActionFailure([super.message = AppStrings.actionAlreadyDone]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = AppStrings.unknownError]);
}

/// Central mapper — every cubit funnels errors through this, so the
/// customer always reads Arabic: Firebase's own (English) messages never
/// reach the screen. Messages a repository wrote on purpose are kept.
Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    // A repository's own (Arabic) wording wins; a raw Firebase message is
    // replaced by the wording for its code.
    ServerException(message: final m) when m.isNotEmpty && !_looksEnglish(m) => ServerFailure(m),
    ServerException(code: final code?) when code.isNotEmpty => _byCode(code),
    ServerException() => const ServerFailure(),
    FirebaseException e => _byCode(e.code),
    NetworkException e => NetworkFailure(e.message),
    CacheException e => CacheFailure(e.message),
    ValidationException e => ValidationFailure(e.message),
    PermissionException e => PermissionFailure(e.message),
    NotFoundException e => NotFoundFailure(e.message),
    DuplicateActionException e => DuplicateActionFailure(e.message),
    _ => const UnknownFailure(),
  };
}

/// Firebase / Firebase Auth error codes → what the customer should read.
Failure _byCode(String code) => switch (code) {
      'unavailable' || 'network-request-failed' || 'deadline-exceeded' => const NetworkFailure(),
      'permission-denied' => const PermissionFailure(AppStrings.actionNotAllowed),
      'not-found' || 'user-not-found' => const NotFoundFailure(),
      'already-exists' => const DuplicateActionFailure(),
      'resource-exhausted' || 'too-many-requests' => const ServerFailure(AppStrings.tooManyAttempts),
      'wrong-password' || 'invalid-credential' => const ValidationFailure(AppStrings.wrongCurrentPassword),
      'weak-password' => const ValidationFailure(AppStrings.weakPassword),
      'requires-recent-login' => const ValidationFailure(AppStrings.signInAgain),
      'unauthenticated' => const PermissionFailure(AppStrings.signInAgain),
      _ => const ServerFailure(),
    };

/// Firebase's raw messages are English; a repository's own are Arabic.
bool _looksEnglish(String s) => !RegExp(r'[\u0600-\u06FF]').hasMatch(s);
