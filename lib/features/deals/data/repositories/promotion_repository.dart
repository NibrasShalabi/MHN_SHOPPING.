import '../../../deals/domain/entities/promotion.dart';

/// Repository for managing promotions (deals for "شرار ونار" section).
abstract class PromotionRepository {
  /// Get all active promotions.
  Future<List<Promotion>> getActivePromotions();

  /// Live active promotions — a deal the admin adds or cancels shows at once.
  Stream<List<Promotion>> watchActivePromotions();

  /// Get a specific promotion by ID.
  Future<Promotion> getPromotion(String promotionId);

  /// Get promotions for a specific product.
  Future<List<Promotion>> getPromotionsForProduct(String productId);

  /// Check if a product has an active promotion.
  Future<bool> hasActivePromotion(String productId);

  /// Get the discount percentage for a product (if any active promotion).
  /// Returns 0 if no active promotion.
  Future<double> getActiveDiscountPercentage(String productId);
}
