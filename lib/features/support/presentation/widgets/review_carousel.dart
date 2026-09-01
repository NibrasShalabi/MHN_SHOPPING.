import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/review.dart';

/// Reviews as a swipeable card deck.
///
/// A vertical list of photo reviews turns into an endless scroll of large
/// images; a deck shows one at a time at full size, which is how photo
/// reviews are actually looked at.
class ReviewCarousel extends StatefulWidget {
  final List<Review> reviews;

  const ReviewCarousel({super.key, required this.reviews});

  @override
  State<ReviewCarousel> createState() => _ReviewCarouselState();
}

class _ReviewCarouselState extends State<ReviewCarousel> {
  // Slightly less than a full page so the neighbouring cards peek in —
  // that edge is what tells the user there's more to swipe to.
  final PageController _controller = PageController(viewportFraction: 0.86);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXl),
        child: Center(
          child: Text(
            AppStrings.noReviewsYet,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: AppConstants.reviewCardHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.reviews.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _ReviewCard(review: widget.reviews[index]),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.reviews.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // TODO(logic-phase): CachedNetworkImage from R2.
            Container(
              color: AppColors.surfaceDark,
              child: const Center(
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: AppConstants.iconXl,
                  color: AppColors.textDisabled,
                ),
              ),
            ),

            // Scrim: the caption sits over the photo, and without this the
            // text is unreadable on a light image.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xE6000000), Color(0x00000000)],
                  stops: [0.0, 0.55],
                ),
              ),
            ),

            Positioned(
              right: AppConstants.spacingMd,
              left: AppConstants.spacingMd,
              bottom: AppConstants.spacingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Stars(count: review.stars),
                  const SizedBox(height: AppConstants.spacingSm),
                  if (review.comment != null)
                    Text(
                      review.comment!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    review.authorName,
                    style: AppTextStyles.caption.copyWith(color: AppColors.goldLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int count;

  const _Stars({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) => Icon(
          index < count ? Icons.star : Icons.star_border,
          size: AppConstants.iconSm,
          color: AppColors.gold,
        ),
      ),
    );
  }
}