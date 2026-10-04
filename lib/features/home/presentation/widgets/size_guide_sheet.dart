import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product_variants.dart';

/// Size chart for one product, opened from the icon beside the sizes.
///
/// A bottom sheet rather than a dialog: the chart can be several rows and
/// needs to scroll on a small screen, which a dialog handles badly.
Future<void> showSizeGuideSheet(BuildContext context, List<SizeGuideRow> rows) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXl)),
    ),
    isScrollControlled: true,
    builder: (context) => _SizeGuideSheet(rows: rows),
  );
}

class _SizeGuideSheet extends StatelessWidget {
  final List<SizeGuideRow> rows;

  const _SizeGuideSheet({required this.rows});

  @override
  Widget build(BuildContext context) {
    // Columns come from the data: a shirt lists chest and length, trousers
    // list waist and inseam, so they can't be hardcoded.
    final columns = rows.isEmpty ? <String>[] : rows.first.measurements.keys.toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  const Icon(
                    Icons.straighten,
                    size: AppConstants.iconMd,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(AppStrings.sizeGuide, style: AppTextStyles.heading2),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Flexible(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(
                      color: AppColors.border,
                      width: AppConstants.borderThin,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: AppColors.surfaceWine),
                        children: [
                          _HeaderCell(text: AppStrings.size),
                          ...columns.map((c) => _HeaderCell(text: c)),
                        ],
                      ),
                      ...rows.map(
                            (row) => TableRow(
                          children: [
                            _Cell(text: row.size, isLeading: true),
                            ...columns.map(
                                  (c) => _Cell(text: row.measurements[c] ?? '—'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                AppStrings.sizeGuideNote,
                style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.goldLight),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isLeading;

  const _Cell({required this.text, this.isLeading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: isLeading ? AppColors.gold : AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}