import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/stream_switch_map.dart';
import '../../domain/entities/admin_message.dart';
import 'messages_repository.dart';

typedef _Snap = QuerySnapshot<Map<String, dynamic>>;

class FirebaseMessagesRepository implements MessagesRepository {
  static const int _broadcastLimit = 50;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseMessagesRepository(this._db, this._auth);

  CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('admin_messages');

  CollectionReference<Map<String, dynamic>> _dismissed(String uid) =>
      _db.collection('users').doc(uid).collection('dismissedMessages');

  @override
  Stream<List<AdminMessage>> watchInbox() => _auth
      .authStateChanges()
      .switchMap((user) => user == null ? Stream.value(const <AdminMessage>[]) : _inbox(user))
      .transform(_mapErrors);

  @override
  Future<void> dismiss(AdminMessage message) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      message.isBroadcast
          ? await _dismissed(uid).doc(message.id).set({'at': FieldValue.serverTimestamp()})
          : await _messages.doc(message.id).update({'isRead': true});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  /// Personal messages, broadcasts sent since the account was made (its
  /// creation time comes from Auth — no read), and broadcasts the admin
  /// marked for new customers too. Old ones are never read at all.
  Stream<List<AdminMessage>> _inbox(User user) {
    final uid = user.uid;
    final broadcasts = _messages.where('type', isEqualTo: 'broadcast');
    final joined = user.metadata.creationTime;
    final streams = [
      _messages
          .where('userId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .snapshots(),
      (joined == null ? broadcasts : broadcasts.where('sentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(joined)))
          .orderBy('sentAt', descending: true)
          .limit(_broadcastLimit)
          .snapshots(),
      broadcasts.where('forNewCustomers', isEqualTo: true).orderBy('sentAt', descending: true).limit(10).snapshots(),
      _dismissed(uid).snapshots(),
    ];

    return _combine(streams, (snaps) {
      final dismissed = snaps.last.docs.map((d) => d.id).toSet();
      final byId = <String, AdminMessage>{
        for (final snap in snaps.take(3))
          for (final doc in snap.docs)
            if (!dismissed.contains(doc.id)) doc.id: _fromDoc(doc),
      };
      return byId.values.toList()..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    });
  }

  /// Emits once every stream has produced, then on every change.
  static Stream<R> _combine<R>(List<Stream<_Snap>> streams, R Function(List<_Snap>) combiner) {
    final latest = List<_Snap?>.filled(streams.length, null);
    final subs = <StreamSubscription<_Snap>>[];
    late final StreamController<R> controller;

    controller = StreamController<R>(
      onListen: () {
        for (final (i, s) in streams.indexed) {
          subs.add(s.listen((snap) {
            latest[i] = snap;
            if (latest.every((x) => x != null)) controller.add(combiner(latest.cast<_Snap>()));
          }, onError: controller.addError));
        }
      },
      onCancel: () => Future.wait(subs.map((s) => s.cancel())),
    );
    return controller.stream;
  }

  static final _mapErrors = StreamTransformer<List<AdminMessage>, List<AdminMessage>>.fromHandlers(
    handleError: (e, st, sink) => sink.addError(
      e is FirebaseException ? ServerException(message: e.message ?? '', code: e.code) : e,
      st,
    ),
  );

  AdminMessage _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return AdminMessage(
      id: doc.id,
      body: d['body'] as String? ?? '',
      sentAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      relatedOrderId: d['orderId'] as String?,
      title: d['title'] as String?,
      // A personal message is never a broadcast, whatever its type says —
      // dismissing it must mark it read, not hide a broadcast. Untyped or
      // unknown personal types read as order updates.
      type: switch (AdminMessageType.fromKey(d['type'] as String?)) {
        AdminMessageType.broadcast when d['userId'] != null => AdminMessageType.orderUpdate,
        final t => t,
      },
    );
  }
}
