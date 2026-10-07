import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../orders/domain/entities/admin_message.dart';

class MessageTile extends StatelessWidget {
  final AdminMessage message;
  final VoidCallback onDismiss;

  const MessageTile({super.key, required this.message, required this.onDismiss});

  IconData get _icon {
    return switch (message.type) {
      AdminMessageType.supportReply => Icons.support_agent,
      AdminMessageType.orderUpdate  => Icons.receipt_long,
      AdminMessageType.broadcast    => Icons.campaign,
    };
  }

  String _typeLabel() {
    return switch (message.type) {
      AdminMessageType.supportReply => AppStrings.messageTypeSupport,
      AdminMessageType.orderUpdate  => AppStrings.messageTypeOrder,
      AdminMessageType.broadcast    => AppStrings.messageBroadcast,
    };
  }

  Color get _accentColor {
    return switch (message.type) {
      AdminMessageType.supportReply => AppColors.gold,
      AdminMessageType.orderUpdate  => Colors.blueAccent,
      AdminMessageType.broadcast    => Colors.deepPurpleAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(message.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(AppStrings.messageDismiss,
            style: AppTextStyles.body.copyWith(color: AppColors.error)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentColor.withOpacity(0.4)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: _accentColor.withOpacity(0.12),
            child: Icon(_icon, color: _accentColor, size: 20),
          ),
          title: Row(
            children: [
              if (message.title != null) ...[
                Flexible(
                  child: Text(message.title!,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_typeLabel(),
                    style: AppTextStyles.caption.copyWith(color: _accentColor)),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(message.body, style: AppTextStyles.body),
          ),
          trailing: Text(
            _formatDate(message.sentAt),
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}';
  }
}