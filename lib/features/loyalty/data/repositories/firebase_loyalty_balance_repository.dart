import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/stream_switch_map.dart';
import '../../domain/entities/loyalty_transaction.dart';
import 'loyalty_balance_repository.dart';

/// One listener on the user's own doc for the whole session: the first
/// snapshot is a single read, every change after that is pushed.
class FirebaseLoyaltyBalanceRepository implements LoyaltyBalanceRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseLoyaltyBalanceRepository(this._db, this._auth);

  @override
  Stream<int> watchBalance() => _auth.authStateChanges().switchMap(
        (user) => user == null
            ? Stream.value(0)
            : _db
                .collection('users')
                .doc(user.uid)
                .snapshots()
                .map((doc) => (doc.data()?['loyaltyPoints'] as num?)?.toInt() ?? 0),
      );

  static const int _historyLimit = 50;

  @override
  Future<List<LoyaltyTransaction>> getHistory() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const [];
    try {
      final snap = await _db
          .collection('loyaltyTransactions')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(_historyLimit)
          .get();
      return [
        for (final doc in snap.docs)
          LoyaltyTransaction(
            id: doc.id,
            points: (doc.data()['points'] as num? ?? 0).toInt(),
            reason: doc.data()['reason'] as String? ?? '',
            orderId: doc.data()['orderId'] as String?,
            createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ),
      ];
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }
}
