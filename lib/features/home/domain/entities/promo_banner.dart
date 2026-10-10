import 'package:equatable/equatable.dart';

/// Where a tap on a banner goes.
enum BannerLink { none, product, category, deals }

class PromoBanner extends Equatable {
  final String id;
  final String? imageUrl;
  final String? title;
  final int order;
  final BannerLink link;
  final String? linkId;
  final DateTime? startsAt;
  final DateTime? endsAt;

  const PromoBanner({
    required this.id,
    this.imageUrl,
    this.title,
    this.order = 0,
    this.link = BannerLink.none,
    this.linkId,
    this.startsAt,
    this.endsAt,
  });

  /// Inside its schedule (no dates = always).
  bool isLiveAt(DateTime now) =>
      (startsAt == null || !now.isBefore(startsAt!)) && (endsAt == null || now.isBefore(endsAt!));

  @override
  List<Object?> get props => [id, imageUrl, title, order, link, linkId, startsAt, endsAt];
}
