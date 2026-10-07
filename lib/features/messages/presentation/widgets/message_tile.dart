import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/admin_message.dart';

class MessageTile extends StatelessWidget {
  final AdminMessage message;
  final VoidCallback onDismiss;

  const MessageTile({super.key, required this.message, required this.onDismiss});

  (IconData, String, Color) get _style => switch (message.type) {
        AdminMessageType.supportReply => (Icons.support_agent, AppStrings.messageTypeSupport, AppColors.gold),
        AdminMessageType.orderUpdate => (Icons.receipt_long, AppStrings.messageTypeOrder, AppColors.info),
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
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: radius,
          border: Border.all(color: accent.withValues(alpha: 0.4), width: AppConstants.borderThin),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          leading: CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Icon(icon, color: accent, size: AppConstants.iconSm + AppConstants.spacingXs),
          ),
          title: Row(
            children: [
              if (message.title case final title?) ...[
                Flexible(
                  child: Text(title,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: AppConstants.spacingSm),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXs + 2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.spacingXs),
                ),
                child: Text(label, style: AppTextStyles.caption.copyWith(color: accent)),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppConstants.spacingXs),
            child: Text(message.body, style: AppTextStyles.body),
          ),
          trailing: Text(
            '${message.sentAt.day}/${message.sentAt.month}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
