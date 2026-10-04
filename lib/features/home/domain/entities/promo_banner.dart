import 'package:equatable/equatable.dart';

class PromoBanner extends Equatable {
  final String id;
  final String? imageUrl;
  final String? title;

  const PromoBanner({required this.id, this.imageUrl, this.title});

  @override
  List<Object?> get props => [id, imageUrl, title];
}