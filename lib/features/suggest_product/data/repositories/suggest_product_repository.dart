import '../../domain/entities/product_suggestion.dart';

abstract class SuggestProductRepository {
  Future<void> submit(ProductSuggestion suggestion);
}
