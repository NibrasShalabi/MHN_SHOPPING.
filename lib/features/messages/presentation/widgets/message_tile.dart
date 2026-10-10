import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/admin_message.dart';

/// One message, laid out top-to-bottom so title and body are always read in
/// full: a meta row (icon, type, date), then the title, then the body.
class MessageTile extends StatelessWidget {
  final AdminMessage message;
  final VoidCallback onDismiss;

  const MessageTile({super.key, required this.message, required this.onDismiss});

  static final DateFormat _date = DateFormat('d MMM · HH:mm', 'ar');

  (IconData, String, Color) get _style => switch (message.type) {
        AdminMessageType.supportReply => (Icons.support_agent, AppStrings.messageTypeSupport, AppColors.gold),
        AdminMessageType.orderUpdate => (Icons.receipt_long, AppStrings.messageTypeOrder, AppColors.info),
        AdminMessageType.suggestion => (Icons.lightbulb_outline, AppStrings.messageTypeSuggestion, AppColors.goldLight),
        AdminMessageType.fitness => (Icons.spa_outlined, AppStrings.messageTypeFitness, AppColors.accentLight),
        AdminMessageType.broadcast => (Icons.campaign, AppStrings.messageBroadcast, AppColors.accent),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, label, accent) = _style;
    final radius = BorderRadius.circular(AppConstants.radiusMd);

    return Dismissible(
      key: ValueKey(message.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: AppConstants.spacingLg),
        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: radius),
        child: Text(AppStrings.messageDismiss, style: AppTextStyles.body.copyWith(color: AppColors.error)),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: radius,
          border: Border.all(color: accent.withValues(alpha: 0.4), width: AppConstants.borderThin),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: AppConstants.iconSm + AppConstants.spacingXs),
                const SizedBox(width: AppConstants.spacingSm),
                Text(label, style: AppTextStyles.caption.copyWith(color: accent)),
                const Spacer(),
                Text(
                  _date.format(message.sentAt),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            if (message.title case final title? when title.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.goldLight)),
            ],
            const SizedBox(height: AppConstants.spacingXs),
            Text(message.body, style: AppTextStyles.body.copyWith(height: 1.6)),
          ],
        ),
      ),
    );
  }
}
