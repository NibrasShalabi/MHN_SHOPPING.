import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/promotion.dart';
import 'promotion_repository.dart';

/// Firebase implementation لـ PromotionRepository
///
/// استراتيجية الـ reads:
/// - Stream للعروض النشطة (real-time — تنتهي تلقائياً بدون polling)
/// - Firestore يفلتر endTime > now مباشرة (ما نفلتر client-side)
class FirebasePromotionRepository implements PromotionRepository {
  final FirebaseFirestore _db;

  FirebasePromotionRepository(this._db);

  /// One read per active deal at start, then only the changed ones.
  @override
  Stream<List<Promotion>> watchActivePromotions() {
    return _db
        .collection('promotions')
        .where('isActive', isEqualTo: true)
        .where('endTime', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList())
        .handleError((Object e) => throw e is FirebaseException
            ? ServerException(message: e.message ?? '', code: e.code)
            : ServerException(message: e.toString()));
  }

  @override
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final snap = await _db
          .collection('promotions')
          .where('isActive', isEqualTo: true)
          .where('endTime', isGreaterThan: Timestamp.now())
          .get();
      return snap.docs.map(_fromDoc).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<Promotion> getPromotion(String promotionId) async {
    try {
      final doc = await _db.collection('promotions').doc(promotionId).get();
      if (!doc.exists) throw const NotFoundException();
      return _fromDoc(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<List<Promotion>> getPromotionsForProduct(String productId) async {
    try {
      final snap = await _db
          .collection('promotions')
          .where('productId', isEqualTo: productId)
          .where('isActive', isEqualTo: true)
          .where('endTime', isGreaterThan: Timestamp.now())
          .get();
      return snap.docs.map(_fromDoc).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
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
    return promos.map((p) => p.discountPercentage).reduce((a, b) => a > b ? a : b);
  }

  // ===== Mapper =====

  Promotion _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Promotion(
      id: doc.id,
      productId: d['productId'] as String? ?? '',
      discountPercentage: (d['discountPercentage'] as num? ?? 0).toDouble(),
      startTime: (d['startTime'] as Timestamp).toDate(),
      endTime: (d['endTime'] as Timestamp).toDate(),
      isActive: d['isActive'] as bool? ?? true,
    );
  }
}