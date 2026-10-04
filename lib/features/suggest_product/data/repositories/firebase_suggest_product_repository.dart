import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
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

  FirebaseSuggestProductRepository(this._db, this._auth);

  @override
  Future<void> submit(ProductSuggestion suggestion) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: 'غير مسجّل دخول');

    try {
      await _db.collection('productSuggestions').add({
        'userId': uid,
        'productName': suggestion.productName,
        'productLink': suggestion.productLink,
        'status': 'pending', // Client دايماً pending — Admin يغيره
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }
}