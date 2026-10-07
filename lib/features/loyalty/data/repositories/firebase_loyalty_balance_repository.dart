import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/stream_switch_map.dart';
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
}
