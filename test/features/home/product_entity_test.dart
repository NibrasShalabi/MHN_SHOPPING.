import 'package:flutter_test/flutter_test.dart';

import 'package:m_h_nshopping/features/home/domain/entities/product.dart';

Product _product({double? discountPct, DateTime? discountEnd}) => Product(
  id: 'p1', categoryId: 'hair', name: 'سيروم 1', price: 100.0, stock: 10,
  discountPercentage: discountPct,
  discountEndTime: discountEnd,
);

void main() {
  group('hasActiveDiscount', () {
    test('6.1 — discountPercentage = null: false', () => expect(_product().hasActiveDiscount, isFalse));
    test('6.2 — discountPercentage = 0: false', () => expect(_product(discountPct: 0).hasActiveDiscount, isFalse));
    test('6.3 — discount > 0 بدون endTime: true', () => expect(_product(discountPct: 25).hasActiveDiscount, isTrue));
    test('6.4 — discount > 0 + endTime مستقبل: true', () {
      expect(_product(discountPct: 25, discountEnd: DateTime.now().add(const Duration(days: 3))).hasActiveDiscount, isTrue);
    });
    test('6.5 — discount > 0 + endTime ماضي: false', () {
      expect(_product(discountPct: 25, discountEnd: DateTime.now().subtract(const Duration(hours: 1))).hasActiveDiscount, isFalse);
    });
  });

  group('effectivePrice', () {
    test('6.6 — بدون خصم: effectivePrice = price', () => expect(_product().effectivePrice, 100.0));
    test('6.7 — خصم 25%: effectivePrice = 75', () => expect(_product(discountPct: 25).effectivePrice, 75.0));
    test('6.8 — خصم منتهي: effectivePrice = price', () {
      expect(
        _product(discountPct: 25, discountEnd: DateTime.now().subtract(const Duration(hours: 1))).effectivePrice,
        100.0,
      );
    });
  });

  group('savingsAmount', () {
    test('6.9 — بدون خصم: savingsAmount = 0', () => expect(_product().savingsAmount, 0.0));
    test('6.10 — خصم 25%: savingsAmount = 25', () => expect(_product(discountPct: 25).savingsAmount, 25.0));
  });
}