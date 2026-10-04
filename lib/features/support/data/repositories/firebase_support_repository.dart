import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/support_message.dart';
import 'support_repository.dart';

/// Firebase implementation لـ SupportRepository
///
/// Security Rules المهمة:
/// - ratings/{uid}: create-only (ما يقدر يعدّل أو يحذف — منع farm للـ loyalty points)
/// - support_messages: create-only للمستخدم المصادق
class FirebaseSupportRepository implements SupportRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // Cache للـ reviews — تتغير نادراً
  List<Review>? _reviewsCache;

  FirebaseSupportRepository(this._db, this._auth);

  /// إرسال رسالة دعم
  @override
  Future<void> sendMessage(SupportMessage message) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    try {
      await _db.collection('support_messages').add({
        'userId': uid,
        'topic': message.topic.name,
        'body': message.body,
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// قراءة التقييمات — مع cache
  @override
  Future<List<Review>> getReviews() async {
    if (_reviewsCache != null) return _reviewsCache!;

    try {
      final snap = await _db
          .collection('reviews')
          .where('isVisible', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      _reviewsCache = snap.docs.map(_reviewFromDoc).toList();
      return _reviewsCache!;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// هل المستخدم قيّم المتجر من قبل؟
  /// ratings/{uid} — document واحد per user
  @override
  Future<bool> hasRated() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      final doc = await _db.collection('ratings').doc(uid).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// حفظ التقييم — create-only (Security Rules تمنع التعديل)
  @override
  @override
  Future<void> submitRating({
    required int stars,
    String? comment,
    String? imagePath,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    try {
      final batch = _db.batch();

      // حفظ التقييم
      batch.set(_db.collection('ratings').doc(uid), {
        'stars': stars,
        'comment': comment,
        'imageUrl': imagePath,
        'createdAt': FieldValue.serverTimestamp(),
        'isVisible': false,
      });

      // إضافة نقاط الولاء
      batch.update(_db.collection('users').doc(uid), {
        'loyaltyPoints': FieldValue.increment(50),
      });

      // تسجيل المعاملة بـ loyaltyTransactions
      batch.set(_db.collection('loyaltyTransactions').doc(), {
        'userId': uid,
        'points': 50,
        'reason': 'تقييم التطبيق',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  // ===== Mapper =====

  Review _reviewFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Review(
      id: doc.id,
      authorName: d['authorName'] as String? ?? '',
      stars: d['stars'] as int? ?? 5,
      comment: d['comment'] as String?,
      imageUrl: d['imageUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}