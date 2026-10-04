import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../cart/domain/entities/cart_item.dart';

/// Service لحفظ الطلب بـ Firestore
/// Transaction: رقم تسلسلي + تحديث المخزون + إضافة الطلب — كلهم atomic
class CheckoutService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CheckoutService(this._db, this._auth);

  Future<String> placeOrder({
    required List<CartItem> items,
    required String paymentMethod,
    required String? txid,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    final total = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    final counterRef = _db.collection('config').doc('orderCounter');

    String orderId = '';

    try {
      await _db.runTransaction((transaction) async {
        // 1. احصل على الرقم التسلسلي
        final counterDoc = await transaction.get(counterRef);
        final lastNumber = counterDoc.data()?['lastOrderNumber'] as int? ?? 0;
        final newNumber = lastNumber + 1;
        orderId = 'ORD-${newNumber.toString().padLeft(6, '0')}';

        // 2. حدّث الـ counter
        transaction.set(
          counterRef,
          {'lastOrderNumber': newNumber},
          SetOptions(merge: true),
        );

        // 3. تحقق من المخزون وحدّثه
        for (final item in items) {
          final productRef = _db.collection('products').doc(item.productId);
          final productDoc = await transaction.get(productRef);

          if (!productDoc.exists) {
            throw ServerException(message: 'المنتج "${item.name}" غير موجود');
          }

          final stock = productDoc.data()?['stock'] as int? ?? 0;
          if (stock < item.quantity) {
            throw ServerException(message: 'نفد مخزون "${item.name}"');
          }

          transaction.update(productRef, {
            'stock': FieldValue.increment(-item.quantity),
          });
        }

        // 4. إضافة الطلب برقمه التسلسلي
        final orderRef = _db.collection('orders').doc(orderId);
        transaction.set(orderRef, {
          'userId': uid,
          'status': 'pending',
          'total': total,
          'paymentMethod': paymentMethod,
          'txid': txid,
          'createdAt': FieldValue.serverTimestamp(),
          'items': items.map((item) => {
            'productId': item.productId,
            'name': item.name,
            'imageUrl': item.imageUrl,
            'priceSnapshot': item.priceSnapshot,
            'quantity': item.quantity,
          }).toList(),
        });
      });

      return orderId;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }
}