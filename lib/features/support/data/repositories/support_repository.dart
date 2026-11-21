import '../../domain/entities/review.dart';
import '../../domain/entities/support_message.dart';

abstract class SupportRepository {
  Future<void> sendMessage(SupportMessage message);

  Future<List<Review>> getReviews();

  /// When this user may rate again, or null when they may rate now. The
  /// once-a-month rule is enforced by the security rules; this only decides
  /// what the screen shows.
  Future<DateTime?> nextRatingAt();

  Future<void> submitRating({required int stars, String? comment});
}
