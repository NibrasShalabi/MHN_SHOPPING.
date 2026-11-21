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

/// A review as a quote: who and when on top, the stars beside them, and
/// the words under a large faint quotation mark.
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  /// "اليوم", "قبل 3 أيام", "قبل شهرين" — reviews read better by age than by date.
  static String _ago(DateTime at) {
    final days = DateTime.now().difference(at).inDays;
    if (days < 1) return AppStrings.today;
    if (days < 30) return AppStrings.daysAgo(days);
    return AppStrings.monthsAgo(days ~/ 30);
  }

  @override
  Widget build(BuildContext context) {
    final name = review.authorName.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
      child: GoldFrame(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.emberGradient,
                      border: Border.all(color: AppColors.goldLight, width: 1.2),
                      boxShadow: [BoxShadow(color: AppColors.flame.withValues(alpha: 0.35), blurRadius: 14)],
                    ),
                    child: GoldText(
                      name.isEmpty ? '؟' : name.characters.first,
                      style: AppTextStyles.heading2.copyWith(height: 1),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoldText(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        Text(_ago(review.createdAt), style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  _Stars(count: review.stars),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Container(height: 1, color: AppColors.goldDark.withValues(alpha: 0.5)),
              Expanded(
                child: Stack(
                  children: [
                    PositionedDirectional(
                      top: 0,
                      start: -6,
                      child: Icon(Icons.format_quote_rounded, size: 72, color: AppColors.gold.withValues(alpha: 0.14)),
                    ),
                    Center(
                      child: Text(
                        review.comment?.trim().isNotEmpty == true ? review.comment!.trim() : AppStrings.reviewNoComment,
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary, height: 1.7),
                      ),
                    ),
                  ],
                ),
              ),
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
          size: AppConstants.iconSm,
          color: AppColors.goldLight,
        ),
      ),
    );
  }
}