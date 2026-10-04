import 'package:equatable/equatable.dart';

/// A customer review shown in the reviews carousel.
class Review extends Equatable {
  final String id;
  final String authorName;
  final int stars;
  final String? comment;

  /// Reviews are expected to be mostly photos, so this drives the card.
  final String? imageUrl;

  final DateTime createdAt;

  const Review({
    required this.id,
    required this.authorName,
    required this.stars,
    this.comment,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authorName, stars, comment, imageUrl, createdAt];
}