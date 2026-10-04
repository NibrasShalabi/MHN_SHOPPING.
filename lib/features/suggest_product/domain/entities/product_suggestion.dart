import 'package:equatable/equatable.dart';

class ProductSuggestion extends Equatable {
  final String productName;
  final String productLink;

  const ProductSuggestion({required this.productName, required this.productLink});

  @override
  List<Object?> get props => [productName, productLink];
}