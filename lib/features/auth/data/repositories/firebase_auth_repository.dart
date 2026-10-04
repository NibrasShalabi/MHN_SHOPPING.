import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/signup_data.dart';
import 'auth_repository.dart';

/// Firebase implementation لـ AuthRepository
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirebaseAuthRepository(this._auth, this._db);

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _mapAuthError(e.code), code: e.code);
    }
  }

  @override
  Future<void> signup(SignupData data) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: data.email.trim(),
        password: data.password,
      );

      final uid = credential.user!.uid;

      // حفظ بيانات المستخدم — gender يتحكم بظهور قسم الرياضة
      await _db.collection('users').doc(uid).set({
        'fullName': data.fullName,
        'familyName': data.familyName,
        'email': data.email.trim(),
        'phone': data.phone,
        'secondaryPhone': data.secondaryPhone,
        'location': data.location,
        'governorate': data.governorate,
        'area': data.area,
        'gender': data.gender.name,
        'loyaltyPoints': 0,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // تحديث عداد المستخدمين — يُقرأ من Admin analytics
      await _db.collection('config').doc('stats').update({
        'totalUsers': FieldValue.increment(1),
      });
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _mapAuthError(e.code), code: e.code);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _mapAuthError(e.code), code: e.code);
    }
  }

  String _mapAuthError(String code) => switch (code) {
    'user-not-found' => 'البريد الإلكتروني غير مسجّل',
    'wrong-password' => 'كلمة المرور غير صحيحة',
    'invalid-credential' => 'بيانات الدخول غير صحيحة',
    'email-already-in-use' => 'البريد الإلكتروني مستخدم مسبقاً',
    'weak-password' => 'كلمة المرور ضعيفة جداً',
    'invalid-email' => 'البريد الإلكتروني غير صالح',
    'user-disabled' => 'الحساب موقوف',
    'too-many-requests' => 'محاولات كثيرة، حاول لاحقاً',
    'network-request-failed' => 'تحقق من الاتصال بالإنترنت',
    _ => 'خطأ غير متوقع، حاول مجدداً',
  };
}