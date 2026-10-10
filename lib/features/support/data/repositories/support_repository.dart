import '../../domain/entities/review.dart';
import '../../domain/entities/support_message.dart';

abstract class SupportRepository {
  Future<void> sendMessage(SupportMessage message);

  Future<List<Review>> getReviews();

  /// Whether this user has already rated. The one-rating rule is enforced
  /// server side; this only decides what the screen shows.
  Future<bool> hasRated();

  Future<void> submitRating({required int stars, String? comment, String? imagePath});
}
