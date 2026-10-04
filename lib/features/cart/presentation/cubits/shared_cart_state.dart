import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';

enum SharedCartStatus { loading, ready, expired, failure }

class SharedCartState extends Equatable {
  final SharedCartStatus status;
  final List<CartItem> items;

  /// Ids the user already copied across, so each row can show it's done
  /// instead of inviting a second tap that would double the quantity.
  final Set<String> savedProductIds;

  final Failure? failure;

  const SharedCartState({
    this.status = SharedCartStatus.loading,
    this.items = const [],
    this.savedProductIds = const {},
    this.failure,
  });

  bool isSaved(String productId) => savedProductIds.contains(productId);

  bool get allSaved =>
      items.isNotEmpty && items.every((i) => savedProductIds.contains(i.productId));

  SharedCartState copyWith({
    SharedCartStatus? status,
    List<CartItem>? items,
    Set<String>? savedProductIds,
    Failure? failure,
  }) {
    return SharedCartState(
      status: status ?? this.status,
      items: items ?? this.items,
      savedProductIds: savedProductIds ?? this.savedProductIds,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, items, savedProductIds, failure];
}