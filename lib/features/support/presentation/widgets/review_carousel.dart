import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/review.dart';
import '../../../../core/widgets/gold_frame.dart';

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

/// A review as a gold-framed card: a big face that matches the stars,
/// glowing like an ember, then the stars, the words and who said them.
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  static String _face(int stars) => switch (stars) {
        >= 5 => '😍',
        4 => '😊',
        3 => '🙂',
        2 => '😕',
        _ => '😞',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
      child: GoldFrame(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 104,
                height: 104,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(colors: [AppColors.ember, AppColors.surfaceDark]),
                  border: Border.all(color: AppColors.goldLight, width: 1.5),
                  boxShadow: [BoxShadow(color: AppColors.flame.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 1)],
                ),
                child: Text(_face(review.stars), style: const TextStyle(fontSize: 56, height: 1)),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _Stars(count: review.stars),
              const Spacer(),
              if (review.comment != null)
                Text(
                  review.comment!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary, height: 1.6),
                ),
              const SizedBox(height: AppConstants.spacingSm),
              GoldText(review.authorName, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
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
          size: AppConstants.iconMd,
          color: AppColors.goldLight,
        ),
      ),
    );
  }
}