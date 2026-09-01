import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/review.dart';

enum RateAppStatus { loading, ready, submitting, submitted, failure }

class RateAppState extends Equatable {
  final RateAppStatus status;

  /// True when this user already rated — the form is replaced by the
  /// reviews list, since rating is once per account.
  final bool hasRated;

  final int stars;
  final String comment;
  final String? imagePath;
  final List<Review> reviews;
  final Failure? failure;

  const RateAppState({
    this.status = RateAppStatus.loading,
    this.hasRated = false,
    this.stars = 0,
    this.comment = '',
    this.imagePath,
    this.reviews = const [],
    this.failure,
  });

  bool get canSubmit => stars > 0;

  RateAppState copyWith({
    RateAppStatus? status,
    bool? hasRated,
    int? stars,
    String? comment,
    String? imagePath,
    List<Review>? reviews,
    Failure? failure,
  }) {
    return RateAppState(
      status: status ?? this.status,
      hasRated: hasRated ?? this.hasRated,
      stars: stars ?? this.stars,
      comment: comment ?? this.comment,
      imagePath: imagePath ?? this.imagePath,
      reviews: reviews ?? this.reviews,
      failure: failure,
    );
  }

  @override
  List<Object?> get props =>
      [status, hasRated, stars, comment, imagePath, reviews, failure];
}