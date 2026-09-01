import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';

/// Vertical category grid — scrolls with the page and handles any number
/// of categories (2 today, 50+ later) without a "see all" screen. Column
/// count is derived from available width, same rule as everywhere else.
class CategoriesGrid extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<Category>? onCategoryTap;

  const CategoriesGrid({super.key, required this.categories, this.onCategoryTap});

  int _columns(double width) {
    final columns = (width / AppConstants.categoryCardMinWidth).floor();
    return columns.clamp(2, 8);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns(constraints.maxWidth),
            crossAxisSpacing: AppConstants.spacingMd,
            mainAxisSpacing: AppConstants.spacingMd,
            childAspectRatio: AppConstants.categoryCardAspectRatio,
          ),
          itemBuilder: (context, index) => _CategoryCard(
            category: categories[index],
            onTap: () => onCategoryTap?.call(categories[index]),
          ),
        );
      },
    );
  }
}

/// A framed plate rather than a plain tile.
///
/// The luxury read comes from three things layered together: a gold
/// hairline around the whole card, an ember glow bleeding out from behind
/// the icon so the plate looks lit from within, and engraved corner
/// brackets. Any one of them alone just looks like a bordered box.
class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: AppColors.goldDark,
            width: AppConstants.borderThin,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xB3000000),
              blurRadius: AppConstants.elevationLg,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base plate: lighter at the top so the surface reads as tilted
            // toward the light rather than flat.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.surfaceElevated, AppColors.surfaceDark],
                ),
              ),
            ),

            // Heat bleeding out from behind the icon.
            Align(
              alignment: const Alignment(0, -0.25),
              child: FractionallySizedBox(
                widthFactor: 0.9,
                heightFactor: 0.7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.ember.withValues(alpha: 0.45),
                        AppColors.emberDeep.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            const _CornerBrackets(),

            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        gradient: AppColors.emberGradient,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(
                          color: AppColors.goldDark,
                          width: AppConstants.borderThin,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.flame.withValues(alpha: 0.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      // TODO(logic-phase): swap for the category image from R2.
                      child: const Icon(
                        Icons.category_outlined,
                        size: AppConstants.iconXl,
                        color: AppColors.goldLight,
                      ),
                    ),
                  ),
                ),
                const _GoldRule(),
                Container(
                  width: double.infinity,
                  color: AppColors.surfaceDark.withValues(alpha: 0.85),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingSm,
                    vertical: AppConstants.spacingSm,
                  ),
                  child: Text(
                    category.name,
                    // Letterspacing is what separates a label from a
                    // caption — it reads as engraved rather than typed.
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.goldLight,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Short gold strokes at the top two corners — the framing device on
/// engraved plates and certificates. Kept to the top only: all four would
/// box the card in and fight the label band.
class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  static const double _length = 16;

  @override
  Widget build(BuildContext context) {
    Widget bracket({required bool isStart}) {
      final side = BorderSide(color: AppColors.gold, width: AppConstants.borderThin);
      return Container(
        width: _length,
        height: _length,
        decoration: BoxDecoration(
          border: BorderDirectional(
            top: side,
            start: isStart ? side : BorderSide.none,
            end: isStart ? BorderSide.none : side,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [bracket(isStart: true), bracket(isStart: false)],
      ),
    );
  }
}

/// Hairline separating the icon from the label, fading out at both ends —
/// same treatment as the rule under the app bar, so the two read as one
/// design language.
class _GoldRule extends StatelessWidget {
  const _GoldRule();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.appBarBorderHeight / 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.transparent,
            AppColors.goldDark,
            AppColors.gold,
            AppColors.goldDark,
            Colors.transparent,
          ],
          stops: [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
      ),
    );
  }
}