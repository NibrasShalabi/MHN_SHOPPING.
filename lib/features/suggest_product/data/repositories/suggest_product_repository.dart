import '../../domain/entities/product_suggestion.dart';

abstract class SuggestProductRepository {
  Future<void> submit(ProductSuggestion suggestion);
}

/// UI-phase implementation.
///
/// NOTE(logic-phase): the real one must go through a Cloud Function, not a
/// direct Firestore write, because three protections can only live server
/// side:
///   1. Re-validate the link (https-only, length, control chars) — client
///      validation is bypassed by anyone calling the API directly.
///   2. Rate limit — cap suggestions per user per day and reject a link
///      the same user already submitted.
///   3. Set `status: pending` server-side; the user must never be able to
///      write the status field, or they could approve their own entry.
///
/// Firestore rules for productSuggestions/{id}: create only for the signed
/// in owner, no read of other users' docs, no update, no delete. App Check
/// on top of that keeps non-app clients out entirely.
class FakeSuggestProductRepository implements SuggestProductRepository {
  @override
  Future<void> submit(ProductSuggestion suggestion) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }
}