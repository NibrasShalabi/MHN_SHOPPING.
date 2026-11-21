import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/review.dart';

enum RateAppStatus { loading, ready, submitting, submitted, failure }

class RateAppState extends Equatable {
  final RateAppStatus status;

  /// When the next rating opens; null while the form is open.
  final DateTime? nextRatingAt;

  final int stars;
  final String comment;
  final List<Review> reviews;
  final Failure? failure;

  const RateAppState({
    this.status = RateAppStatus.loading,
    this.nextRatingAt,
    this.stars = 0,
    this.comment = '',
    this.reviews = const [],
    this.failure,
  });

  bool get canRate => nextRatingAt == null;
  bool get canSubmit => canRate && stars > 0;

  RateAppState copyWith({
    RateAppStatus? status,
    DateTime? Function()? nextRatingAt,
    int? stars,
    String? comment,
    List<Review>? reviews,
    Failure? failure,
  }) {
    return RateAppState(
      status: status ?? this.status,
      nextRatingAt: nextRatingAt != null ? nextRatingAt() : this.nextRatingAt,
      stars: stars ?? this.stars,
      comment: comment ?? this.comment,
      reviews: reviews ?? this.reviews,
      failure: failure,
    );
  }

  @override
  List<Object?> get props =>
      [status, nextRatingAt, stars, comment, reviews, failure];
}