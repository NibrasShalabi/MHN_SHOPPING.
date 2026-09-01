import '../../domain/entities/admin_message.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status.dart';

abstract class OrdersRepository {
  /// Only returns orders inside the retention window — see
  /// [OrdersRetention]. Anything older is not shown to the user at all.
  Future<List<OrderEntity>> getOrders();

  Future<List<AdminMessage>> getMessages();

  /// Dismissing is permanent: the message leaves the inbox.
  Future<void> dismissMessage(String messageId);
}

/// How long an order stays visible to the user.
///
/// NOTE(logic-phase): the Firestore query must filter on createdAt within
/// this window, AND a scheduled Cloud Function should archive/delete older
/// order documents — otherwise the collection grows forever and the "no
/// orders older than this" rule only holds on the client.
class OrdersRetention {
  OrdersRetention._();

  static const Duration window = Duration(days: 25);

  static bool isVisible(DateTime createdAt) =>
      DateTime.now().difference(createdAt) <= window;
}

/// UI-phase implementation.
class FakeOrdersRepository implements OrdersRepository {
  final List<AdminMessage> _messages = [
    AdminMessage(
      id: 'm1',
      body: 'نعتذر عن التأخير في طلبك بسبب ضغط الطلبات، سيصلك خلال 24 ساعة.',
      sentAt: DateTime.now().subtract(const Duration(hours: 3)),
      relatedOrderId: 'ORD-1042',
    ),
    AdminMessage(
      id: 'm2',
      body: 'شكراً لتعاونك، تم توفير المنتج الذي اقترحته، اطّلع عليه.',
      sentAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AdminMessage(
      id: 'm3',
      body: 'نعتذر، تم إلغاء طلبك. سيتم التواصل معك خلال 24 ساعة لإعادة المبلغ المدفوع.',
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
      relatedOrderId: 'ORD-1035',
    ),
  ];

  @override
  Future<List<OrderEntity>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final orders = [
      OrderEntity(
        id: 'ORD-1042',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: OrderStatus.preparing,
        total: 77500,
        expectedDelivery: DateTime.now().add(const Duration(hours: 20)),
        lines: const [
          OrderLine(productId: 'p1', name: 'سيروم 1', quantity: 2, price: 16250),
          OrderLine(productId: 'p2', name: 'كريمات 3', quantity: 1, price: 45000),
        ],
      ),
      OrderEntity(
        id: 'ORD-1038',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        status: OrderStatus.delivered,
        total: 32000,
        lines: const [
          OrderLine(productId: 'p6', name: 'غسول يومي', quantity: 1, price: 32000),
        ],
      ),
      // Outside the retention window — filtered out below, kept here so the
      // rule is actually exercised during the UI phase.
      OrderEntity(
        id: 'ORD-0900',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        status: OrderStatus.delivered,
        total: 19000,
        lines: const [
          OrderLine(productId: 'p3', name: 'شامبو مرطب', quantity: 1, price: 19000),
        ],
      ),
    ];

    return orders.where((o) => OrdersRetention.isVisible(o.createdAt)).toList();
  }

  @override
  Future<List<AdminMessage>> getMessages() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_messages);
  }

  @override
  Future<void> dismissMessage(String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
  }
}