import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_durations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';

/// Collapsible text block (ingredients, benefits, usage...).
///
/// The details page carries several long text blocks; showing them all
/// open at once buries the price and the add-to-cart button below a very
/// long scroll. Only the description is expanded by default.
class ExpandableSection extends StatefulWidget {
  final String title;
  final String content;
  final bool initiallyExpanded;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _isExpanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppConstants.minTouchTarget),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: AppConstants.spacingSm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: AppDurations.fast,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.gold,
                        size: AppConstants.iconMd,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: AppDurations.fast,
            crossFadeState:
            _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMd,
                0,
                AppConstants.spacingMd,
                AppConstants.spacingMd,
              ),
              child: Text(
                widget.content,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}