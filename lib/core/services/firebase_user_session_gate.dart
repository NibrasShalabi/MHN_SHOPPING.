import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../router/app_router.dart';

/// Firebase implementation لـ UserSessionGate
/// يستبدل FakeUserSessionGate في main.dart
///
/// isFemale: يُقرأ من Firestore users/{uid}.gender
/// مهم: قسم الرياضة واللياقة لا يظهر للذكور أبداً
class FirebaseUserSessionGate implements UserSessionGate {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Cache للـ gender — يُقرأ مرة واحدة فقط
  bool? _isFemaleCache;

  FirebaseUserSessionGate(this._auth, this._firestore);

  @override
  bool get isLoggedIn => _auth.currentUser != null;

  /// يُقرأ من Firestore users/{uid}.gender
  /// مع cache لتجنب reads متكررة
  @override
  bool get isFemale => _isFemaleCache ?? false;

  /// استدعيها بعد تسجيل الدخول مباشرة
  Future<void> loadUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _isFemaleCache = null;
      return;
    }
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      _isFemaleCache = (doc.data()?['gender'] as String?) == 'female';
    } catch (_) {
      _isFemaleCache = false;
    }
  }

  /// مسح الـ cache عند تسجيل الخروج
  void clearCache() => _isFemaleCache = null;
}