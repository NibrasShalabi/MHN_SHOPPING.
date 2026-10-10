import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/promotion.dart';
import 'promotion_repository.dart';

/// Active deals come from one live listener (opened by LivePromotions at
/// app start). Once it has delivered, every other lookup — the home page,
/// a product page's price — is answered from it with no extra read.
class FirebasePromotionRepository implements PromotionRepository {
  final FirebaseFirestore _db;

  FirebasePromotionRepository(this._db);

  /// The listener's latest snapshot; null until it first delivers.
  List<Promotion>? _live;

  List<Promotion>? get _liveNow => _live?.where((p) => p.isActive && !p.isExpired).toList();

  /// One read per active deal at start, then only the changed ones.
  @override
  Stream<List<Promotion>> watchActivePromotions() {
    return _db
        .collection('promotions')
        .where('isActive', isEqualTo: true)
        .where('endTime', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snap) => _live = snap.docs.map(_fromDoc).toList())
        .handleError((Object e) => throw e is FirebaseException
            ? ServerException(message: e.message ?? '', code: e.code)
            : ServerException(message: e.toString()));
  }

  @override
  Future<List<Promotion>> getActivePromotions() async {
    if (_liveNow case final live?) return live;
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
    if (_liveNow case final live?) return live.where((p) => p.productId == productId).toList();
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