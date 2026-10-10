import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_profile.dart';
import 'account_repository.dart';

class FirebaseAccountRepository implements AccountRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseAccountRepository(this._db, this._auth);

  Future<UserProfile>? _profile;
  String? _profileUid;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const ServerException(message: AppStrings.notSignedIn);
    return uid;
  }

  @override
  Future<UserProfile> profile({bool refresh = false}) {
    final uid = _uid;
    if (refresh || _profileUid != uid) _profile = null;
    _profileUid = uid;
    return _profile ??= _load(uid).catchError((Object e) {
      _profile = null; // a failed read is retried next time
      throw e;
    });
  }

  Future<UserProfile> _load(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final d = doc.data() ?? const <String, dynamic>{};
    return UserProfile.fromMap(d, updatedAt: (d['profileUpdatedAt'] as Timestamp?)?.toDate())
        .copyEmail(_auth.currentUser?.email);
  }

  @override
  Future<UserProfile> updateProfile(UserProfile p) async {
    final uid = _uid;
    final current = await profile();
    final wait = current.nextEditAt(DateTime.now());
    if (wait != null) throw ServerException(message: AppStrings.profileEditTooSoon(wait));

    await _db.collection('users').doc(uid).update({
      'fullName': p.fullName,
      'familyName': p.familyName,
      'phone': p.phone,
      'secondaryPhone': p.secondaryPhone,
      'governorate': p.governorate,
      'area': p.area,
      'profileUpdatedAt': FieldValue.serverTimestamp(),
    });
    final saved = current.edited(
      fullName: p.fullName,
      familyName: p.familyName,
      phone: p.phone,
      secondaryPhone: p.secondaryPhone,
      governorate: p.governorate,
      area: p.area,
      at: DateTime.now(),
    );
    _profile = Future.value(saved);
    return saved;
  }

  /// Firebase asks for a recent sign-in before a password change, so the
  /// current password is checked first.
  @override
  Future<void> changePassword({required String current, required String next}) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) throw const ServerException(message: AppStrings.notSignedIn);
    await user.reauthenticateWithCredential(EmailAuthProvider.credential(email: email, password: current));
    await user.updatePassword(next);
  }

  @override
  Future<void> signOut() async {
    clear();
    await _auth.signOut();
  }

  @override
  void clear() {
    _profile = null;
    _profileUid = null;
  }
}

extension on UserProfile {
  /// The sign-in email is the source of truth for display.
  UserProfile copyEmail(String? email) => email == null || email.isEmpty
      ? this
      : UserProfile(
          fullName: fullName,
          familyName: familyName,
          email: email,
          phone: phone,
          secondaryPhone: secondaryPhone,
          governorate: governorate,
          area: area,
          isFemale: isFemale,
          profileUpdatedAt: profileUpdatedAt,
        );
}
