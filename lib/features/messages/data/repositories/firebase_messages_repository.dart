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
      .switchMap((user) => user == null ? Stream.value(const <AdminMessage>[]) : _inbox(user.uid))
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

  Stream<List<AdminMessage>> _inbox(String uid) {
    final personal = _messages
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .orderBy('sentAt', descending: true)
        .snapshots();
    final broadcast = _messages
        .where('type', isEqualTo: 'broadcast')
        .orderBy('sentAt', descending: true)
        .limit(_broadcastLimit)
        .snapshots();

    return _combine(personal, broadcast, _dismissed(uid).snapshots(), (p, b, d) {
      final dismissedIds = d.docs.map((doc) => doc.id).toSet();
      return [
        ...p.docs.map(_fromDoc),
        ...b.docs.where((doc) => !dismissedIds.contains(doc.id)).map(_fromDoc),
      ]..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    });
  }

  /// Emits once all three streams have produced, then on every change.
  static Stream<R> _combine<R>(
    Stream<_Snap> a,
    Stream<_Snap> b,
    Stream<_Snap> c,
    R Function(_Snap, _Snap, _Snap) combiner,
  ) {
    final latest = List<_Snap?>.filled(3, null);
    final subs = <StreamSubscription<_Snap>>[];
    late final StreamController<R> controller;

    controller = StreamController<R>(
      onListen: () {
        for (final (i, s) in [a, b, c].indexed) {
          subs.add(s.listen((snap) {
            latest[i] = snap;
            if (latest.every((x) => x != null)) {
              controller.add(combiner(latest[0]!, latest[1]!, latest[2]!));
            }
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
      type: AdminMessageType.fromKey(d['type'] as String?),
    );
  }
}
