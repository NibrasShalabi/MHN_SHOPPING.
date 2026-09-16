import '../../../deals/domain/entities/promotion.dart';

/// Repository for managing promotions (deals for "شرار ونار" section).
abstract class PromotionRepository {
  /// Get all active promotions.
  Future<List<Promotion>> getActivePromotions();

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

/// Fake implementation for UI phase.
/// In logic phase, this connects to Firestore.
class FakePromotionRepository implements PromotionRepository {
  /// Sample promotions — in real phase these come from Firestore.
  static final List<Promotion> _promotions = [
    Promotion(
      id: 'promo_1',
      productId: 'hair_serum_1',
      discountPercentage: 70,
      startTime: DateTime.now().subtract(const Duration(hours: 5)),
      endTime: DateTime.now().add(const Duration(hours: 19)),
      isActive: true,
    ),
    Promotion(
      id: 'promo_2',
      productId: 'skin_cream_2',
      discountPercentage: 50,
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 22)),
      isActive: true,
    ),
    Promotion(
      id: 'promo_3',
      productId: 'hair_oils_3',
      discountPercentage: 40,
      startTime: DateTime.now().subtract(const Duration(hours: 8)),
      endTime: DateTime.now().add(const Duration(hours: 16)),
      isActive: true,
    ),
    Promotion(
      id: 'promo_4',
      productId: 'skin_cleanser_1',
      discountPercentage: 60,
      startTime: DateTime.now().subtract(const Duration(days: 2)),
      endTime: DateTime.now().subtract(const Duration(hours: 1)),
      isActive: false, // Expired
    ),
  ];

  @override
  Future<List<Promotion>> getActivePromotions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    return _promotions
        .where((p) => now.isBefore(p.endTime) && p.isActive)
        .toList();
  }

  @override
  Future<Promotion> getPromotion(String promotionId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _promotions.firstWhere((p) => p.id == promotionId);
    } catch (e) {
      throw Exception('Promotion not found: $promotionId');
    }
  }

  @override
  Future<List<Promotion>> getPromotionsForProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now();
    return _promotions
        .where((p) => p.productId == productId)
        .where((p) => now.isBefore(p.endTime) && p.isActive)
        .toList();
  }

  @override
  Future<bool> hasActivePromotion(String productId) async {
    final promos = await getPromotionsForProduct(productId);
    return promos.isNotEmpty;
  }

  @override
  Future<double> getActiveDiscountPercentage(String productId) async {
    final promos = await getPromotionsForProduct(productId);
    if (promos.isEmpty) return 0;

    // If multiple promotions exist (shouldn't happen), return the highest
    return promos.map((p) => p.discountPercentage).reduce((a, b) => a > b ? a : b);
  }

  /// Admin method: Create a new promotion (not in abstract class yet).
  /// Will be used by admin dashboard.
  Future<void> createPromotion({
    required String productId,
    required double discountPercentage,
    required int durationHours,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final id = 'promo_${DateTime.now().millisecondsSinceEpoch}';
    final newPromo = Promotion(
      id: id,
      productId: productId,
      discountPercentage: discountPercentage,
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: durationHours)),
      isActive: true,
    );

    _promotions.add(newPromo);
  }

  /// Admin method: Cancel a promotion.
  Future<void> cancelPromotion(String promotionId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _promotions.indexWhere((p) => p.id == promotionId);
    if (index != -1) {
      final promo = _promotions[index];
      _promotions[index] = Promotion(
        id: promo.id,
        productId: promo.productId,
        discountPercentage: promo.discountPercentage,
        startTime: promo.startTime,
        endTime: DateTime.now(), // End immediately
        isActive: false,
      );
    }
  }
}