import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/data/rate_limit.dart';
import '../../../account/data/repositories/account_repository.dart';
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
  final AccountRepository _account;

  // Cache للـ reviews — تتغير نادراً
  // Reviews change rarely, but a review the admin removes must leave the
  // store within minutes, not at the next app restart.
  static const Duration _reviewsTtl = Duration(minutes: 10);
  List<Review>? _reviewsCache;
  DateTime? _reviewsAt;

  FirebaseSupportRepository(this._db, this._auth, this._account);

  /// The name is stored on the message so the admin never reads users per
  /// message; it comes from the session's profile cache (no extra read).
  @override
  Future<void> sendMessage(SupportMessage message) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    try {
      final userName = (await _account.profile()).displayName;
      final batch = _db.batch();
      RateLimit.stamp(_db, batch, uid, RateLimited.support);
      batch.set(_db.collection('support_messages').doc(), {
        'userId': uid,
        if (userName.isNotEmpty) 'userName': userName,
        'topic': message.topic.name,
        'body': message.body,
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      await batch.commit();
      RateLimit.sent(RateLimited.support);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// قراءة التقييمات — مع cache
  @override
  Future<List<Review>> getReviews() async {
    final at = _reviewsAt;
    if (_reviewsCache != null && at != null && DateTime.now().difference(at) < _reviewsTtl) return _reviewsCache!;

    try {
      final snap = await _db
          .collection('reviews')
          .where('isVisible', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      _reviewsCache = snap.docs.map(_reviewFromDoc).toList();
      _reviewsAt = DateTime.now();
      return _reviewsCache!;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// هل المستخدم قيّم المتجر من قبل؟
  /// ratings/{uid} — document واحد per user
  /// A user rates once a month; each rating earns the admin's points.
  static const Duration ratingInterval = Duration(days: 30);

  DateTime? _lastRatedAt;
  bool _hasRating = false;

  @override
  Future<DateTime?> nextRatingAt() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final d = (await _db.collection('ratings').doc(uid).get()).data();
      _hasRating = d != null;
      _lastRatedAt = ((d?['ratedAt'] ?? d?['createdAt']) as Timestamp?)?.toDate();
      final next = _lastRatedAt?.add(ratingInterval);
      return next != null && next.isAfter(DateTime.now()) ? next : null;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// The rating, the points and their log in one batch — the rules accept
  /// the points only with a rating written in the same request.
  @override
  Future<void> submitRating({required int stars, String? comment}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: AppStrings.notSignedIn);

    try {
      // The admin's value — the rules reject any other number.
      final rules = (await _db.collection('config').doc('loyaltyRules').get()).data() ?? const {};
      final rewardEnabled = rules['appRatingRuleEnabled'] as bool? ?? true;
      final reward = (rules['appRatingPoints'] as num?)?.toInt() ?? 0;
      final now = DateTime.now();
      final month = '${now.year}${now.month.toString().padLeft(2, '0')}';

      final batch = _db.batch()
        ..set(
          _db.collection('ratings').doc(uid),
          {
            'stars': stars,
            'comment': comment,
            'ratedAt': FieldValue.serverTimestamp(),
            'isVisible': false,
            if (!_hasRating) 'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

      if (rewardEnabled && reward > 0) {
        batch
          ..update(_db.collection('users').doc(uid), {'loyaltyPoints': FieldValue.increment(reward)})
          // One log entry per month.
          ..set(_db.collection('loyaltyTransactions').doc('rating_${uid}_$month'), {
            'userId': uid,
            'points': reward,
            'reason': 'تقييم التطبيق',
            'createdAt': FieldValue.serverTimestamp(),
          });
      }

      await batch.commit();
      _hasRating = true;
      _lastRatedAt = now;
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