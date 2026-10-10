import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/data/rate_limit.dart';
import '../../../account/data/repositories/account_repository.dart';
import '../../domain/entities/product_suggestion.dart';
import 'suggest_product_repository.dart';

/// Firebase implementation لـ SuggestProductRepository
///
/// Security Rules:
/// - productSuggestions/{id}: create-only للمستخدم المصادق
/// - لا قراءة، لا تعديل، لا حذف من الـ client
/// - status: 'pending' دايماً من الـ client — Admin هو اللي يغيره
class FirebaseSuggestProductRepository implements SuggestProductRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final AccountRepository _account;

  FirebaseSuggestProductRepository(this._db, this._auth, this._account);

  @override
  Future<void> submit(ProductSuggestion suggestion) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    try {
      // الاسم بينحفظ مع الاقتراح — الأدمن ما بيحتاج يقرأ users لكل اقتراح
      final userName = (await _account.profile()).displayName;
      final batch = _db.batch();
      RateLimit.stamp(_db, batch, uid, RateLimited.suggestion);
      batch.set(_db.collection('productSuggestions').doc(), {
        'userId': uid,
        if (userName.isNotEmpty) 'userName': userName,
        'productName': suggestion.productName,
        'productLink': suggestion.productLink,
        'status': 'pending', // Client دايماً pending — Admin يغيره
        'submittedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      RateLimit.sent(RateLimited.suggestion);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }
}