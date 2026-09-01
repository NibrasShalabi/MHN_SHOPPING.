import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/surface_card.dart';
import '../../domain/entities/admin_message.dart';

/// Admin message row. Tapping dismisses it for good, so every message
/// carries the unread treatment — there is no "read but still here" state.
class AdminMessageTile extends StatelessWidget {
  final AdminMessage message;
  final VoidCallback onDismiss;

  const AdminMessageTile({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(message.id),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: const Icon(Icons.check, color: AppColors.gold),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: const Icon(Icons.check, color: AppColors.gold),
      ),
      child: SurfaceCard(
        onTap: onDismiss,
        borderColor: AppColors.gold,
        margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                  ),
                  if (message.relatedOrderId != null) ...[
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      message.relatedOrderId!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
