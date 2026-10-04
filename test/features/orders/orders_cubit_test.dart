import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:m_h_nshopping/features/orders/data/repositories/orders_repository.dart';
import 'package:m_h_nshopping/features/orders/domain/entities/admin_message.dart';
import 'package:m_h_nshopping/features/orders/domain/entities/order_entity.dart';
import 'package:m_h_nshopping/features/orders/domain/entities/order_status.dart';
import 'package:m_h_nshopping/features/orders/presentation/cubits/orders_cubit.dart';
import 'package:m_h_nshopping/features/orders/presentation/cubits/orders_state.dart';

class _FakeOrdersRepository implements OrdersRepository {
  final List<OrderEntity> _orders;
  List<AdminMessage> _messages;
  final bool _shouldThrow;

  _FakeOrdersRepository({
    List<OrderEntity>? orders,
    List<AdminMessage>? messages,
    bool shouldThrow = false,
  })  : _orders = orders ?? [],
        _messages = messages ?? [],
        _shouldThrow = shouldThrow;

  @override
  Future<List<OrderEntity>> getOrders() async {
    if (_shouldThrow) throw Exception('error');
    return _orders;
  }

  @override
  Future<List<AdminMessage>> getMessages() async {
    if (_shouldThrow) throw Exception('error');
    return _messages;
  }

  @override
  Future<void> dismissMessage(String messageId) async {
    _messages = _messages.where((m) => m.id != messageId).toList();
  }
}

OrderEntity _order(String id, OrderStatus status) => OrderEntity(
  id: id,
  status: status,
  lines: const [],
  total: 50.0,
  createdAt: DateTime(2026, 1, 1),
);

AdminMessage _msg(String id) => AdminMessage(
  id: id,
  body: 'رسالة $id',
  sentAt: DateTime(2026, 1, 1),
);

void main() {
  group('load()', () {
    // 4.1
    blocTest<OrdersCubit, OrdersState>(
      '4.1 — ناجح: orders + messages تظهر',
      build: () => OrdersCubit(_FakeOrdersRepository(
        orders: [_order('o1', OrderStatus.pending), _order('o2', OrderStatus.delivered)],
        messages: [_msg('m1'), _msg('m2')],
      )),
      act: (c) => c.load(),
      expect: () => [
        const OrdersState(status: OrdersStatus.loading),
        isA<OrdersState>()
            .having((s) => s.status, 'status', OrdersStatus.success)
            .having((s) => s.orders.length, 'orders', 2)
            .having((s) => s.messages.length, 'messages', 2),
      ],
    );

    // 4.2
    blocTest<OrdersCubit, OrdersState>(
      '4.2 — فاشل: status = failure',
      build: () => OrdersCubit(_FakeOrdersRepository(shouldThrow: true)),
      act: (c) => c.load(),
      expect: () => [
        const OrdersState(status: OrdersStatus.loading),
        isA<OrdersState>()
            .having((s) => s.status, 'status', OrdersStatus.failure)
            .having((s) => s.failure, 'failure', isNotNull),
      ],
    );
  });

  group('dismissMessage()', () {
    // 4.3
    blocTest<OrdersCubit, OrdersState>(
      '4.3 — dismissMessage: الرسالة تختفي',
      build: () => OrdersCubit(_FakeOrdersRepository(messages: [_msg('m1'), _msg('m2')])),
      seed: () => OrdersState(status: OrdersStatus.success, messages: [_msg('m1'), _msg('m2')]),
      act: (c) => c.dismissMessage('m1'),
      expect: () => [
        isA<OrdersState>()
            .having((s) => s.messages.length, 'count', 1)
            .having((s) => s.messages.first.id, 'remaining', 'm2'),
      ],
    );

    // 4.7
    blocTest<OrdersCubit, OrdersState>(
      '4.7 — ما في رسائل: messages = []',
      build: () => OrdersCubit(_FakeOrdersRepository(orders: [], messages: [])),
      act: (c) => c.load(),
      expect: () => [
        const OrdersState(status: OrdersStatus.loading),
        isA<OrdersState>().having((s) => s.messages, 'messages', isEmpty),
      ],
    );
  });

  group('OrdersState getters', () {
    // 4.4
    test('4.4 — activeOrders: طلبيات غير منتهية فقط', () {
      final state = OrdersState(
        status: OrdersStatus.success,
        orders: [
          _order('o1', OrderStatus.pending),
          _order('o2', OrderStatus.confirmed),
          _order('o3', OrderStatus.delivered),
          _order('o4', OrderStatus.cancelled),
        ],
      );
      expect(state.activeOrders.length, 2);
      expect(state.activeOrders.every((o) => !o.status.isFinished), isTrue);
    });

    // 4.5
    test('4.5 — pastOrders: طلبيات منتهية فقط', () {
      final state = OrdersState(
        status: OrdersStatus.success,
        orders: [
          _order('o1', OrderStatus.pending),
          _order('o2', OrderStatus.delivered),
          _order('o3', OrderStatus.cancelled),
        ],
      );
      expect(state.pastOrders.length, 2);
      expect(state.pastOrders.every((o) => o.status.isFinished), isTrue);
    });

    // 4.6
    test('4.6 — كل الطلبيات منتهية: activeOrders = []', () {
      final state = OrdersState(
        status: OrdersStatus.success,
        orders: [
          _order('o1', OrderStatus.delivered),
          _order('o2', OrderStatus.cancelled),
        ],
      );
      expect(state.activeOrders, isEmpty);
    });
  });
}