import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/promo_banner.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<PromoBanner> banners;
  final List<Category> categories;
  final Failure? failure;

  const HomeState({
    this.status = HomeStatus.initial,
    this.banners = const [],
    this.categories = const [],
    this.failure,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<PromoBanner>? banners,
    List<Category>? categories,
    Failure? failure,
  }) {
    return HomeState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, banners, categories, failure];
}