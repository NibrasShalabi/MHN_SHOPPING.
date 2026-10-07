import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubits/messages_cubit.dart';
import '../cubits/messages_state.dart';
import '../widgets/message_tile.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWine,
        title: Text(AppStrings.messagesTitle, style: AppTextStyles.heading2),
        centerTitle: true,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(AppConstants.borderThin),
          child: Divider(height: AppConstants.borderThin, color: AppColors.border),
        ),
      ),
      body: BlocConsumer<MessagesCubit, MessagesState>(
        listenWhen: (prev, curr) =>
            curr.status == MessagesStatus.ready && curr.failure != null && prev.failure != curr.failure,
        listener: (context, state) => AppSnackbar.error(context, state.failure!.message),
        builder: (context, state) => switch (state.status) {
          MessagesStatus.initial || MessagesStatus.loading =>
            const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          MessagesStatus.failure => _Centered(
              child: Text(
                state.failure?.message ?? AppStrings.somethingWentWrong,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          MessagesStatus.ready when state.messages.isEmpty => const _EmptyInbox(),
          MessagesStatus.ready => ListView.separated(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
                horizontal: AppConstants.spacingSm + AppConstants.spacingXs,
              ),
              itemCount: state.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingSm),
              itemBuilder: (context, i) {
                final msg = state.messages[i];
                return MessageTile(
                  message: msg,
                  onDismiss: () => context.read<MessagesCubit>().dismiss(msg),
                );
              },
            ),
        },
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return _Centered(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: AppConstants.iconXl, color: AppColors.gold.withValues(alpha: 0.4)),
          const SizedBox(height: AppConstants.spacingMd),
          Text(AppStrings.noMessages, style: AppTextStyles.heading2),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            AppStrings.noMessagesSubtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  final Widget child;
  const _Centered({required this.child});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(padding: const EdgeInsets.all(AppConstants.spacingLg), child: child),
      );
}
