import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/supplier.dart';

enum SuppliersStatus { initial, loading, success, failure }

class SuppliersState extends Equatable {
  final SuppliersStatus status;
  final List<Supplier> suppliers;
  final Failure? failure;

  const SuppliersState({
    this.status = SuppliersStatus.initial,
    this.suppliers = const [],
    this.failure,
  });

  SuppliersState copyWith({
    SuppliersStatus? status,
    List<Supplier>? suppliers,
    Failure? failure,
  }) {
    return SuppliersState(
      status: status ?? this.status,
      suppliers: suppliers ?? this.suppliers,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, suppliers, failure];
}