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

/// UI-phase implementation.
///
/// NOTE(logic-phase): the rating must be a document keyed by uid so the
/// Firestore rule can allow create-if-absent and forbid update and delete
/// outright. Anything softer lets a user re-rate and farm the loyalty
/// points that come with it. Support messages need rate limiting for the
/// same reason.
class FakeSupportRepository implements SupportRepository {
  bool _hasRated = false;

  @override
  Future<void> sendMessage(SupportMessage message) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<List<Review>> getReviews() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      Review(
        id: 'r1',
        authorName: 'سارة',
        stars: 5,
        comment: 'المنتجات أصلية والتوصيل كان أسرع من المتوقع.',
        imageUrl: '',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'r2',
        authorName: 'رهف',
        stars: 4,
        comment: 'جودة ممتازة، أنصح بها.',
        imageUrl: '',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Review(
        id: 'r3',
        authorName: 'ليان',
        stars: 5,
        comment: 'خدمة العملاء ردّت عليّ خلال دقائق.',
        imageUrl: '',
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
      ),
    ];
  }

  @override
  Future<bool> hasRated() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _hasRated;
  }

  @override
  Future<void> submitRating({
    required int stars,
    String? comment,
    String? imagePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _hasRated = true;
  }
}