import 'package:flutter_test/flutter_test.dart';

import 'package:m_h_nshopping/features/deals/domain/entities/promotion.dart';

Promotion _promo({required double discount, required DateTime endTime}) => Promotion(
  id: 'p1',
  productId: 'prod1',
  discountPercentage: discount,
  startTime: DateTime.now().subtract(const Duration(hours: 1)),
  endTime: endTime,
);

void main() {
  group('isExpired', () {
    // 5.1
    test('5.1 — endTime بالمستقبل: isExpired = false', () {
      expect(
        _promo(discount: 50, endTime: DateTime.now().add(const Duration(hours: 5))).isExpired,
        isFalse,
      );
    });

    // 5.2
    test('5.2 — endTime بالماضي: isExpired = true', () {
      expect(
        _promo(discount: 50, endTime: DateTime.now().subtract(const Duration(hours: 1))).isExpired,
        isTrue,
      );
    });
  });

  group('getDiscountedPrice', () {
    // 5.3
    test('5.3 — خصم 0%: السعر ما يتغير', () {
      final promo = _promo(discount: 0, endTime: DateTime.now().add(const Duration(hours: 24)));
      expect(promo.getDiscountedPrice(100.0), 100.0);
    });

    // 5.4
    test('5.4 — خصم 50%: نص السعر', () {
      final promo = _promo(discount: 50, endTime: DateTime.now().add(const Duration(hours: 24)));
      expect(promo.getDiscountedPrice(100.0), 50.0);
    });

    // 5.5
    test('5.5 — خصم 70%: 30% من الأصلي', () {
      final promo = _promo(discount: 70, endTime: DateTime.now().add(const Duration(hours: 24)));
      expect(promo.getDiscountedPrice(100.0), closeTo(30.0, 0.001));
    });

    // 5.6
    test('5.6 — خصم 100%: السعر = 0', () {
      final promo = _promo(discount: 100, endTime: DateTime.now().add(const Duration(hours: 24)));
      expect(promo.getDiscountedPrice(100.0), 0.0);
    });
  });

  // 5.7
  group('remainingDuration', () {
    test('5.7 — remainingDuration: تقريباً صح', () {
      final promo = _promo(
        discount: 50,
        endTime: DateTime.now().add(const Duration(hours: 5)),
      );
      expect(promo.remainingDuration.inSeconds, closeTo(5 * 3600, 2));
    });
  });
}