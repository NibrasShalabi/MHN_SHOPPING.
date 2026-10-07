import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../../orders/domain/entities/admin_message.dart';
import 'messages_repository.dart';

class FirebaseMessagesRepository implements MessagesRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseMessagesRepository(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<List<AdminMessage>> getMessages() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final personal = await _db
          .collection('admin_messages')
          .where('userId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .get();

      final broadcast = await _db
          .collection('admin_messages')
          .where('type', isEqualTo: 'broadcast')
          .where('isRead', isEqualTo: false)
          .orderBy('sentAt', descending: true)
          .get();

      final seen = <String>{};
      final all = [...personal.docs, ...broadcast.docs]
          .where((d) => seen.add(d.id))
          .map(_fromDoc)
          .toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

      return all;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  @override
  Future<void> dismissMessage(String messageId) async {
    try {
      await _db.collection('admin_messages').doc(messageId).update({'isRead': true});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? '', code: e.code);
    }
  }

  AdminMessage _fromDoc(doc) {
    final d = doc.data() as Map<String, dynamic>;
    final type = switch (d['type'] as String? ?? 'broadcast') {
      'support_reply' => AdminMessageType.supportReply,
      'order_update'  => AdminMessageType.orderUpdate,
      _               => AdminMessageType.broadcast,
    };
    return AdminMessage(
      id: doc.id,
      body: d['body'] as String? ?? '',
      sentAt: (d['sentAt'] as Timestamp).toDate(),
      relatedOrderId: d['orderId'] as String?,
      title: d['title'] as String?,
      type: type,
    );
  }
}