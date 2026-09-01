//   import 'package:flutter/material.dart';
//
// import '../../../../../core/constants/app_constants.dart';
// import '../../../../../core/constants/app_durations.dart';
// import '../../../../../core/theme/app_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../domain/entities/promo_banner.dart';
//
// /// Image-first promo carousel. The image fills the whole card; the title
// /// is optional and only rendered when the admin actually set one — most
// /// banners are expected to be image-only, with the text baked into the
// /// artwork.
// class PromoSwiper extends StatefulWidget {
//   final List<PromoBanner> banners;
//
//   const PromoSwiper({super.key, required this.banners});
//
//   @override
//   State<PromoSwiper> createState() => _PromoSwiperState();
// }
//
// class _PromoSwiperState extends State<PromoSwiper> {
//   final PageController _controller = PageController();
//   int _currentPage = 0;
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.banners.isEmpty) return const SizedBox.shrink();
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final height = constraints.maxWidth / AppConstants.swiperAspectRatio;
//         return Column(
//           children: [
//             SizedBox(
//               height: height,
//               child: PageView.builder(
//                 controller: _controller,
//                 itemCount: widget.banners.length,
//                 onPageChanged: (index) => setState(() => _currentPage = index),
//                 itemBuilder: (context, index) => _BannerCard(banner: widget.banners[index]),
//               ),
//             ),
//             if (widget.banners.length > 1) ...[
//               const SizedBox(height: AppConstants.spacingSm),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(widget.banners.length, (index) {
//                   final isActive = index == _currentPage;
//                   return AnimatedContainer(
//                     duration: AppDurations.fast,
//                     margin: const EdgeInsets.symmetric(horizontal: 3),
//                     width: isActive ? 18 : 6,
//                     height: 6,
//                     decoration: BoxDecoration(
//                       color: isActive ? AppColors.gold : AppColors.border,
//                       borderRadius: BorderRadius.circular(AppConstants.radiusSm),
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _BannerCard extends StatelessWidget {
//   final PromoBanner banner;
//
//   const _BannerCard({required this.banner});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(AppConstants.radiusLg),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // TODO(logic-phase): swap for CachedNetworkImage once banner
//             // images are served from R2 — placeholder keeps the wine tone
//             // so the palette still reads while artwork is missing.
//             Container(color: AppColors.primary),
//
//             if (banner.title != null)
//               Positioned(
//                 right: AppConstants.spacingMd,
//                 bottom: AppConstants.spacingMd,
//                 left: AppConstants.spacingMd,
//                 child: Text(
//                   banner.title!,
//                   style: AppTextStyles.heading2.copyWith(color: AppColors.textOnPrimary),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
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
class PromoSwiper extends StatefulWidget {
  final List<PromoBanner> banners;

  const PromoSwiper({super.key, required this.banners});

  @override
  State<PromoSwiper> createState() => _PromoSwiperState();
}

class _PromoSwiperState extends State<PromoSwiper> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
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
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.banners.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _BannerCard(banner: widget.banners[index]),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // TODO(logic-phase): swap for CachedNetworkImage once banner
            // images are served from R2 — the fire ramp stands in so the
            // palette still reads while artwork is missing.
            Container(
              decoration: const BoxDecoration(gradient: AppColors.fireGradient),
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