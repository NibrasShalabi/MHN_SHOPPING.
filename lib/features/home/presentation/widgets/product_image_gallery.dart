import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_durations.dart';
import '../../../../../core/theme/app_colors.dart';

/// Swipeable product images with a dot indicator.
class ProductImageGallery extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImageGallery({super.key, required this.imageUrls});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.imageUrls.isEmpty ? 1 : widget.imageUrls.length;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (index) => setState(() => _currentPage = index),
            // TODO(logic-phase): swap for CachedNetworkImage served from R2,
            // using the full-resolution variant here (thumbnails stay on the
            // product cards).
            itemBuilder: (context, index) => Container(
              color: AppColors.surfaceDark,
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.textDisabled,
                size: AppConstants.iconXl,
              ),
            ),
          ),
          if (count > 1)
            Positioned(
              bottom: AppConstants.spacingMd,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (index) {
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
            ),
        ],
      ),
    );
  }
}