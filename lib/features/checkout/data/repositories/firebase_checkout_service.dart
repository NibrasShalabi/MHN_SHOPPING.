import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order_breakdown.dart';
import '../../domain/entities/shipping_rates.dart';

class CheckoutService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  CheckoutService(this._db, this._auth, FirebaseStorage? storage)
    : _storage = storage ?? FirebaseStorage.instance;

  static const paymentMethods = ['trc20', 'bep20', 'erc20', 'sham_cash'];

  /// Enabled methods only, in display order — from config/payment_addresses,
  /// which the admin edits. A method with no address or switched off is left out.
  Future<Map<String, String>> getPaymentAddresses() async {
    try {
      final data = (await _db.collection('config').doc('payment_addresses').get()).data() ?? const {};
      final disabled = (data['disabled'] as List? ?? const []).cast<String>().toSet();
      return {
        for (final m in paymentMethods)
          if ((data[m] as String?)?.trim() case final address? when address.isNotEmpty && !disabled.contains(m))
            m: address,
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

  Future<ShippingRates> getShippingRates() async {
    try {
      return ShippingRates.fromMap((await _db.collection('config').doc('shipping').get()).data() ?? const {});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  Future<String?> getGovernorate() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      return (await _db.collection('users').doc(uid).get()).data()?['governorate'] as String?;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// Everything the customer owes is computed here from the product docs,
  /// active promotions, the shipping table and the customer's governorate —
  /// never from the cart. The admin re-checks it with the same formula.
  Future<String> placeOrder({
    required List<CartItem> items,
    required String paymentMethod,
    String? txid,
    String? receiptUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    final normalizedTxid = txid?.trim().toLowerCase();
    if (normalizedTxid != null && (normalizedTxid.isEmpty || normalizedTxid.contains('/'))) {
      throw const ServerException(message: AppStrings.txidInvalid);
    }

    final counterRef = _db.collection('config').doc('orderCounter');
    final txidRef = normalizedTxid == null ? null : _db.collection('usedTxids').doc(normalizedTxid);
    String orderId = '';

    try {
      // Promotions are queried by productId — transactions only read docs by
      // id, so they're fetched just before.
      final promos = await _activePromotions(items.map((i) => i.productId).toSet().toList());

      await _db.runTransaction((transaction) async {
        // ===== ALL READS FIRST =====
        final counterDoc = await transaction.get(counterRef);
        final productDocs = await Future.wait(
          items.map((item) => transaction.get(_db.collection('products').doc(item.productId))),
        );
        final userDoc = await transaction.get(_db.collection('users').doc(uid));
        final shippingDoc = await transaction.get(_db.collection('config').doc('shipping'));
        final txidDoc = txidRef == null ? null : await transaction.get(txidRef);

        // ===== VALIDATION =====
        if (txidDoc?.exists ?? false) throw const ServerException(message: AppStrings.txidUsed);

        final newNumber = (counterDoc.data()?['lastOrderNumber'] as int? ?? 0) + 1;
        orderId = 'ORD-${newNumber.toString().padLeft(6, '0')}';

        final products = [for (final d in productDocs) d.data()];
        for (int i = 0; i < items.length; i++) {
          final p = products[i];
          if (p == null) throw ServerException(message: 'المنتج "${items[i].name}" غير موجود');
          // Consult-only items (fitness) are ordered by the specialist, never from the cart.
          if (p['isOrderable'] == false) throw ServerException(message: AppStrings.consultOnlyItem(items[i].name));
          // Deal-only products exist for their deal alone — once it ends they can't be bought.
          if (p['dealOnly'] == true && !promos.containsKey(items[i].productId)) {
            throw ServerException(message: AppStrings.dealEnded(items[i].name));
          }
          if ((p['stock'] as int? ?? 0) < items[i].quantity) {
            throw ServerException(message: 'نفد مخزون "${items[i].name}"');
          }
        }

        bool isPoints(int i) => products[i]!['pricing'] == 'points';
        double unitPrice(int i) => _unitPrice(products[i]!, promos[items[i].productId] ?? 0);
        double shippingPerUnit(int i) => (products[i]!['shippingPrice'] as num? ?? 0).toDouble();

        final user = userDoc.data() ?? const <String, dynamic>{};
        final breakdown = OrderBreakdown.compute(
          lines: [
            for (int i = 0; i < items.length; i++)
              if (!isPoints(i)) (unitPrice: unitPrice(i), shippingPerUnit: shippingPerUnit(i), quantity: items[i].quantity),
          ],
          rates: ShippingRates.fromMap(shippingDoc.data() ?? const {}),
          governorate: user['governorate'] as String?,
        );

        var pointsTotal = 0;
        for (int i = 0; i < items.length; i++) {
          if (isPoints(i)) pointsTotal += ((products[i]!['price'] as num? ?? 0) * items[i].quantity).round();
        }
        // تحقق مبكر فقط — الخصم الفعلي بيعمله الأدمن لما يأكد الطلب
        final balance = (user['loyaltyPoints'] as num?)?.toInt() ?? 0;
        if (pointsTotal > balance) {
          throw ServerException(message: AppStrings.notEnoughPointsDetail(pointsTotal, balance));
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
          'itemsTotal': breakdown.itemsTotal,
          'supplyShipping': breakdown.supplyShipping,
          'deliveryFee': breakdown.deliveryFee,
          'total': breakdown.total,
          ..._customerSnapshot(user),
          if (pointsTotal > 0) 'pointsTotal': pointsTotal,
          'paymentMethod': paymentMethod,
          'txid': ?normalizedTxid,
          'receiptUrl': ?receiptUrl,
          'paymentStatus': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'items': [
            for (int i = 0; i < items.length; i++)
              {
                'productId': items[i].productId,
                'name': items[i].name,
                'imageUrl': items[i].imageUrl,
                'quantity': items[i].quantity,
                'pricing': isPoints(i) ? 'points' : 'money',
                'unitPrice': isPoints(i) ? (products[i]!['price'] as num? ?? 0).toDouble() : unitPrice(i),
                'shippingPerUnit': isPoints(i) ? 0.0 : shippingPerUnit(i),
              },
          ],
        });

        // One TXID can pay for one order only.
        if (txidRef != null) {
          transaction.set(txidRef, {'orderId': orderId, 'createdAt': FieldValue.serverTimestamp()});
        }
      });

      return orderId;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// After the admin rejects a payment: a new TXID or receipt puts it back
  /// to pending. Rules allow only these fields, only from 'rejected'.
  Future<void> resubmitPayment({required String orderId, String? txid, String? receiptUrl}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    final normalizedTxid = txid?.trim().toLowerCase();
    if (normalizedTxid != null && (normalizedTxid.isEmpty || normalizedTxid.contains('/'))) {
      throw const ServerException(message: AppStrings.txidInvalid);
    }
    final orderRef = _db.collection('orders').doc(orderId);
    final txidRef = normalizedTxid == null ? null : _db.collection('usedTxids').doc(normalizedTxid);

    try {
      await _db.runTransaction((tx) async {
        final order = (await tx.get(orderRef)).data();
        final txidDoc = txidRef == null ? null : await tx.get(txidRef);
        if (order == null || order['userId'] != uid || order['paymentStatus'] != 'rejected') {
          throw const ServerException(message: AppStrings.somethingWentWrong);
        }
        if (txidDoc?.exists ?? false) throw const ServerException(message: AppStrings.txidUsed);

        tx.update(orderRef, {
          'txid': ?normalizedTxid,
          'receiptUrl': ?receiptUrl,
          'paymentStatus': 'pending',
          'paymentRejectReason': FieldValue.delete(),
          'paymentResubmittedAt': FieldValue.serverTimestamp(),
        });
        if (txidRef != null) tx.set(txidRef, {'orderId': orderId, 'createdAt': FieldValue.serverTimestamp()});
      });
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// Best live promotion per product (same rule as the product page).
  Future<Map<String, double>> _activePromotions(List<String> productIds) async {
    final now = DateTime.now();
    final best = <String, double>{};
    for (var i = 0; i < productIds.length; i += 30) {
      final chunk = productIds.sublist(i, (i + 30).clamp(0, productIds.length));
      final snap = await _db.collection('promotions').where('productId', whereIn: chunk).get();
      for (final doc in snap.docs) {
        final p = doc.data();
        final start = (p['startTime'] as Timestamp?)?.toDate();
        final end = (p['endTime'] as Timestamp?)?.toDate();
        final live = p['isActive'] != false && (start == null || !now.isBefore(start)) && (end == null || now.isBefore(end));
        final pct = (p['discountPercentage'] as num? ?? 0).toDouble();
        final id = p['productId'] as String;
        if (live && pct > (best[id] ?? 0)) best[id] = pct;
      }
    }
    return best;
  }

  /// A promotion wins over the product's own discount, as on the product page.
  double _unitPrice(Map<String, dynamic> product, double promoPct) {
    final price = (product['price'] as num? ?? 0).toDouble();
    final ownPct = (product['discountPercentage'] as num? ?? 0).toDouble();
    final ownEnd = (product['discountEndTime'] as Timestamp?)?.toDate();
    final ownLive = ownPct > 0 && (ownEnd == null || DateTime.now().isBefore(ownEnd));
    final pct = promoPct > 0 ? promoPct : (ownLive ? ownPct : 0);
    return price * (1 - pct / 100);
  }

  Map<String, dynamic> _customerSnapshot(Map<String, dynamic> u) {
    String? text(String key) {
      final v = (u[key] as String?)?.trim();
      return v == null || v.isEmpty ? null : v;
    }

    final name = '${text('fullName') ?? ''} ${text('familyName') ?? ''}'.trim();
    return {
      if (name.isNotEmpty) 'customerName': name,
      'customerPhone': ?text('phone'),
      'customerSecondaryPhone': ?text('secondaryPhone'),
      'governorate': ?text('governorate'),
      'area': ?text('area'),
      'gender': ?text('gender'),
    };
  }
}
