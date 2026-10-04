import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// نقطة وصول مركزية لكل Firebase services
/// المسار: lib/core/firebase/firebase_service.dart
class FirebaseService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'default',
  ),
        auth = auth ?? FirebaseAuth.instance {
    // تفعيل Offline Persistence — يُقلّل الـ reads بشكل كبير
    this.firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  User? get currentUser => auth.currentUser;
  String? get currentUserId => auth.currentUser?.uid;
  bool get isLoggedIn => auth.currentUser != null;
  Stream<User?> get authStateChanges => auth.authStateChanges();

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      firestore.collection(path);

  DocumentReference<Map<String, dynamic>> doc(String path) =>
      firestore.doc(path);

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  Future<T> runTransaction<T>(TransactionHandler<T> updateFunction) =>
      firestore.runTransaction(updateFunction);

  WriteBatch get batch => firestore.batch();
}