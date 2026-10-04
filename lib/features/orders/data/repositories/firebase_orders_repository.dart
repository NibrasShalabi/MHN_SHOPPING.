import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/admin_message.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.dart';
import 'orders_repository.dart';

/// Firebase implementation لـ OrdersRepository
/// الـ reads محسّنة:
/// - Orders: Stream (تحديث فوري عند تغيير الـ status)
/// - Messages: Future (تُقرأ مرة واحدة)
/// - Retention window: 25 يوم (يُفلتر بـ Firestore query مباشرة)
class FirebaseOrdersRepository implements OrdersRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseOrdersRepository(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  /// قراءة طلبيات المستخدم — الـ 25 يوم الأخيرة فقط
  /// Stream: بيتحدث تلقائياً لما Admin يغير الـ status
  Stream<List<OrderEntity>> watchOrders() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(OrdersRetention.window),
    );

    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .where('createdAt', isGreaterThan: cutoff)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_orderFromDoc).toList())
        .handleError((e) => throw ServerException(message: e.toString()));
  }

  /// Future للـ orders (الـ cubit الحالي يستخدم Future)
  @override
  Future<List<OrderEntity>> getOrders() async {
    final uid = _uid;
    if (uid == null) return [];

    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(OrdersRetention.window),
    );

    try {
      final snap = await _db
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .where('createdAt', isGreaterThan: cutoff)
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs.map(_orderFromDoc).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// رسائل الـ Admin للمستخدم
  @override
  Future<List<AdminMessage>> getMessages() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final snap = await _db
          .collection('admin_messages')
          .where('userId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .get();

      return snap.docs.map(_messageFromDoc).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// حذف رسالة — تُعلّم كـ isRead بدل الحذف الفعلي
  /// السبب: Admin قد يحتاج يرى إحصائيات الرسائل المقروءة
  @override
  Future<void> dismissMessage(String messageId) async {
    try {
      await _db
          .collection('admin_messages')
          .doc(messageId)
          .update({'isRead': true});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  // ===== Mappers =====

  OrderEntity _orderFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return OrderEntity(
      id: doc.id,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      status: OrderStatus.values.firstWhere(
            (s) => s.name == (d['status'] as String? ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      total: (d['total'] as num? ?? 0).toDouble(),
      expectedDelivery: d['expectedDelivery'] != null
          ? (d['expectedDelivery'] as Timestamp).toDate()
          : null,
      statusNote: d['statusNote'] as String?,
      lines: (d['items'] as List<dynamic>? ?? [])
          .map((item) => OrderLine(
        productId: item['productId'] as String? ?? '',
        name: item['name'] as String? ?? '',
        quantity: item['quantity'] as int? ?? 1,
        price: (item['priceSnapshot'] as num? ?? 0).toDouble(),
      ))
          .toList(),
    );
  }

  AdminMessage _messageFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AdminMessage(
      id: doc.id,
      body: d['body'] as String? ?? '',
      sentAt: (d['sentAt'] as Timestamp).toDate(),
      relatedOrderId: d['orderId'] as String?,
    );
  }
}