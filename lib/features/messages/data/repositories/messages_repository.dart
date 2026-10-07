import '../../../orders/domain/entities/admin_message.dart';

abstract class MessagesRepository {
  Future<List<AdminMessage>> getMessages();
  Future<void> dismissMessage(String messageId);
}