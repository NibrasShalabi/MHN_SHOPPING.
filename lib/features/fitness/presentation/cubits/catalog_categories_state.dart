import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/category.dart';

enum CatalogCategoriesStatus { initial, loading, success, failure }

class CatalogCategoriesState extends Equatable {
  final CatalogCategoriesStatus status;
  final List<Category> categories;
  final Failure? failure;

  const CatalogCategoriesState({
    this.status = CatalogCategoriesStatus.initial,
    this.categories = const [],
    this.failure,
  });

  CatalogCategoriesState copyWith({
    CatalogCategoriesStatus? status,
    List<Category>? categories,
    Failure? failure,
  }) {
    return CatalogCategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, categories, failure];
}