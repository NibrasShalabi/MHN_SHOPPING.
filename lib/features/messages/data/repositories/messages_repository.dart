import '../../domain/entities/admin_message.dart';

abstract class MessagesRepository {
  /// Live inbox for the signed-in user: unread personal messages plus
  /// broadcasts this user hasn't dismissed. Emits `[]` while signed out.
  Stream<List<AdminMessage>> watchInbox();

  /// Personal → marked read on the message itself.
  /// Broadcast → recorded per user, the shared message stays untouched.
  Future<void> dismiss(AdminMessage message);
}
