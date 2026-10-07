import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/error/exceptions.dart';
import '../../../cart/domain/entities/cart_item.dart';

class CheckoutService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  CheckoutService(this._db, this._auth, FirebaseStorage? storage)
    : _storage = storage ?? FirebaseStorage.instance;

  /// يجيب عناوين الدفع من config/payment_addresses
  Future<Map<String, String>> getPaymentAddresses() async {
    try {
      final doc = await _db.collection('config').doc('payment_addresses').get();
      final data = doc.data() ?? {};
      return {
        'trc20': data['trc20'] as String? ?? '',
        'bep20': data['bep20'] as String? ?? '',
        'erc20': data['erc20'] as String? ?? '',
        'sham_cash': data['sham_cash'] as String? ?? '',
      };
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// يرفع إيصال شام كاش لـ Firebase Storage
  /// يرجع الـ download URL
  /// يرفع إيصال شام كاش — يدعم ويب وموبايل
  Future<String> uploadReceipt({
    required String orderId,
    required dynamic file, // PlatformFile
  }) async {
    try {
      final uid = _auth.currentUser?.uid ?? 'unknown';
      final ext = file.name.split('.').last;
      final ref = _storage
          .ref()
          .child('receipts')
          .child(uid)
          .child('$orderId.$ext');

      TaskSnapshot task;
      if (kIsWeb) {
        final bytes = file.bytes as Uint8List;
        task = await ref.putData(bytes);
      } else {
        task = await ref.putFile(File(file.path!));
      }
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  Future<String> placeOrder({
    required List<CartItem> items,
    required String paymentMethod,
    String? txid,
    String? receiptUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    final total = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    final counterRef = _db.collection('config').doc('orderCounter');

    String orderId = '';

    try {
      await _db.runTransaction((transaction) async {
        // ===== ALL READS FIRST =====
        final counterDoc = await transaction.get(counterRef);
        final productDocs = await Future.wait(
          items.map((item) => transaction.get(
            _db.collection('products').doc(item.productId),
          )),
        );

        // ===== VALIDATION =====
        final lastNumber = counterDoc.data()?['lastOrderNumber'] as int? ?? 0;
        final newNumber = lastNumber + 1;
        orderId = 'ORD-${newNumber.toString().padLeft(6, '0')}';

        for (int i = 0; i < items.length; i++) {
          if (!productDocs[i].exists) {
            throw ServerException(message: 'المنتج "${items[i].name}" غير موجود');
          }
          final stock = productDocs[i].data()?['stock'] as int? ?? 0;
          if (stock < items[i].quantity) {
            throw ServerException(message: 'نفد مخزون "${items[i].name}"');
          }
        }

        // ===== ALL WRITES AFTER =====
        transaction.set(counterRef, {'lastOrderNumber': newNumber}, SetOptions(merge: true));

        for (int i = 0; i < items.length; i++) {
          transaction.update(
            _db.collection('products').doc(items[i].productId),
            {'stock': FieldValue.increment(-items[i].quantity)},
          );
        }

        transaction.set(_db.collection('orders').doc(orderId), {
          'userId': uid,
          'status': 'pending',
          'total': total,
          'paymentMethod': paymentMethod,
          if (txid != null) 'txid': txid,
          if (receiptUrl != null) 'receiptUrl': receiptUrl,
          'paymentStatus': 'pending',
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
