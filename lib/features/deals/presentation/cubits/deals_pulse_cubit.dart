import 'dart:async';

import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../data/repositories/live_promotions.dart';
import '../../domain/entities/promotion.dart';

/// What the fire deals banner shows: how many deals are live, and whether
/// one started after this device last opened the section.
class DealsPulse {
  final int count;
  final bool hasNew;

  const DealsPulse({this.count = 0, this.hasNew = false});

  bool get isLive => count > 0;
}

class DealsPulseCubit extends SafeCubit<DealsPulse> {
  final LivePromotions _promotions;
  StreamSubscription<List<Promotion>>? _sub;
  List<Promotion> _live = const [];

  DealsPulseCubit(this._promotions) : super(const DealsPulse()) {
    _sub = _promotions.watch().listen((live) {
      _live = live;
      _emit();
    }, onError: (_) {});
  }

  /// Called when the section is opened — the dot goes out until a newer deal.
  Future<void> markSeen() async {
    await SharedPrefsService.setDealsSeenAt(DateTime.now());
    _emit();
  }

  void _emit() {
    final seenAt = SharedPrefsService.dealsSeenAt;
    emit(DealsPulse(
      count: _live.length,
      hasNew: _live.any((p) => seenAt == null || p.startTime.isAfter(seenAt)),
    ));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
