import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_durations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/promo_banner.dart';

/// Image-first promo carousel. The image fills the whole card; the title
/// is optional and only rendered when the admin actually set one — most
/// banners are expected to be image-only, with the text baked into the
/// artwork.
///
/// Loops forever, forward only, with no visible "jump back to the start"
/// — the itemCount is a large multiple of the real banner count, and each
/// page maps back to a real banner with `% banners.length`. Advancing
/// past the end just keeps counting up through virtual pages that map to
/// the same real ones, so the loop is seamless.
class PromoSwiper extends StatefulWidget {
  final List<PromoBanner> banners;

  const PromoSwiper({super.key, required this.banners});

  @override
  State<PromoSwiper> createState() => _PromoSwiperState();
}

class _PromoSwiperState extends State<PromoSwiper> {
  static const int _virtualMultiplier = 5000;

  late final PageController _controller;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  int get _realCount => widget.banners.length;
  int get _startPage => (_virtualMultiplier * _realCount) ~/ 2;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _startPage);
    _currentPage = _startPage;
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (_realCount <= 1) return;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(AppDurations.swiperAutoPlay, (_) {
      if (!_controller.hasClients) return;
      _controller.nextPage(duration: AppDurations.normal, curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth / AppConstants.swiperAspectRatio;
        return Column(
          children: [
            SizedBox(
              height: height,
              // A manual swipe still works normally — the timer just
              // keeps nudging it forward again afterward, it doesn't
              // fight the user's gesture.
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _autoPlayTimer?.cancel();
                  } else if (notification is ScrollEndNotification) {
                    _startAutoPlay();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _virtualMultiplier * _realCount,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index % _realCount),
                  itemBuilder: (context, index) =>
                      _BannerCard(banner: widget.banners[index % _realCount]),
                ),
              ),
            ),
            if (widget.banners.length > 1) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.banners.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: AppDurations.fast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.gold : AppColors.border,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final PromoBanner banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    final hasImage = banner.imageUrl != null && banner.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(
                banner.imageUrl!,
                fit: BoxFit.cover,
                // A failed load (bad URL, offline) falls back to the
                // fire ramp rather than a broken-image icon — same
                // placeholder as "no image set at all".
                errorBuilder: (context, error, stackTrace) => const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.fireGradient),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.fireGradient),
                  );
                },
              )
            else
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.fireGradient),
              ),

            if (banner.title != null)
              Positioned(
                right: AppConstants.spacingMd,
                bottom: AppConstants.spacingMd,
                left: AppConstants.spacingMd,
                child: Text(
                  banner.title!,
                  style: AppTextStyles.heading2.copyWith(color: AppColors.textOnPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}