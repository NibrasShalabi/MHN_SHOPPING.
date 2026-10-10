import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_strings.dart';
import '../error/exceptions.dart';

/// Actions a customer can only repeat after a pause. Each submit stamps
/// rateLimits/{uid}.<field> in the same batch, and the security rules
/// refuse the write when the previous stamp is too recent — the limit
/// holds even for a modified app. The local check only spares a doomed
/// round trip and gives a clear message.
enum RateLimited {
  support('support', Duration(minutes: 2)),
  suggestion('suggestion', Duration(minutes: 10)),
  fitness('fitness', Duration(minutes: 10));

  final String field;

  /// Must match the rules in firestore.rules.
  final Duration gap;
  const RateLimited(this.field, this.gap);
}

abstract final class RateLimit {
  static final Map<RateLimited, DateTime> _last = {};

  /// Adds the stamp to [batch]; throws before any network call when the
  /// same action was sent from this device too recently.
  static void stamp(FirebaseFirestore db, WriteBatch batch, String uid, RateLimited action) {
    final last = _last[action];
    if (last != null && DateTime.now().difference(last) < action.gap) {
      throw const ServerException(message: AppStrings.tooSoonRetry);
    }
    batch.set(db.collection('rateLimits').doc(uid), {action.field: FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  /// Called after the batch commits.
  static void sent(RateLimited action) => _last[action] = DateTime.now();
}
