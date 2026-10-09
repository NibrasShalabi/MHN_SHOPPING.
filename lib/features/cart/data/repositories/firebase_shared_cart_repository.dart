import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/cart_item.dart';
import 'shared_cart_repository.dart';

/// Firebase implementation لـ SharedCartRepository
///
/// Security Rules المهمة:
/// - sharedCarts/{cartId}: read by anyone با الـ id (public read)
/// - sharedCarts/{cartId}: write للمستخدم المصادق فقط
/// - TTL: 7 أيام — يُحذف تلقائياً بـ Cloud Function أو بالـ TTL policy
class FirebaseSharedCartRepository implements SharedCartRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // TTL للـ shared cart
  static const Duration _ttl = Duration(days: 7);

  FirebaseSharedCartRepository(this._db, this._auth);

  /// نشر السلة وإرجاع الـ id للمشاركة
  /// الـ snapshot محمي من التعديل — يُحفظ مرة واحدة
  @override
  Future<String> shareCart(List<CartItem> items) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    try {
      final ref = await _db.collection('sharedCarts').add({
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(_ttl)),
        'items': items.map((item) => item.toMap()).toList(),
      });

      return ref.id;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// قراءة سلة مشتركة بالـ id
  /// null لو انتهت صلاحيتها أو ما موجودة
  @override
  Future<List<CartItem>?> getSharedCart(String cartId) async {
    try {
      final doc = await _db.collection('sharedCarts').doc(cartId).get();
      if (!doc.exists) return null;

      final d = doc.data()!;

      // تحقق من الـ TTL
      final expiresAt = (d['expiresAt'] as Timestamp?)?.toDate();
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) return null;

      final items = (d['items'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList();

      return items;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }
}