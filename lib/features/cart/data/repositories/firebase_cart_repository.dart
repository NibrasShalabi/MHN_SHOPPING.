import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_repository.dart';

/// Firebase implementation لـ CartRepository
///
/// استراتيجية الـ reads:
/// - السلة: document واحد فقط per user → cart/{userId}
/// - getItems: 1 read
/// - saveItems: 1 write (كل السلة دفعة واحدة)
/// - التزامن بين الأجهزة: Firestore offline persistence بتتكفل فيه
class FirebaseCartRepository implements CartRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseCartRepository(this._db, this._auth);

  /// مرجع document السلة للمستخدم الحالي
  DocumentReference<Map<String, dynamic>>? get _cartRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('cart').doc(uid);
  }

  /// قراءة السلة — 1 read فقط
  @override
  Future<List<CartItem>> getItems() async {
    final ref = _cartRef;
    if (ref == null) return [];

    try {
      final doc = await ref.get();
      if (!doc.exists) return [];

      final items = doc.data()?['items'] as List<dynamic>? ?? [];
      return items.map(_itemFromMap).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// حفظ السلة كاملة — 1 write فقط
  /// الـ cubit يـdebounce الاستدعاءات لتجنب الـ writes المتكررة
  @override
  Future<void> saveItems(List<CartItem> items) async {
    final ref = _cartRef;
    if (ref == null) return;

    try {
      await ref.set({
        'items': items.map(_itemToMap).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  // ===== Mappers =====

  CartItem _itemFromMap(dynamic map) => CartItem.fromMap(map as Map<String, dynamic>);

  Map<String, dynamic> _itemToMap(CartItem item) => item.toMap();
}