import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubits/messages_cubit.dart';
import '../cubits/messages_state.dart';
import '../widgets/message_tile.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MessagesCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.surfaceElevated,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWine,
          title: Text(AppStrings.messagesTitle, style: AppTextStyles.heading2),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border),
          ),
        ),
        body: BlocBuilder<MessagesCubit, MessagesState>(
          builder: (context, state) {
            if (state.status == MessagesStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            if (state.status == MessagesStatus.failure) {
              return Center(
                child: Text(
                  AppStrings.somethingWentWrong,  // بدل state.failure?.message
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
              );
            }

            if (state.messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64,
                        color: AppColors.gold.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(AppStrings.noMessages, style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.noMessagesSubtitle,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: state.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final msg = state.messages[i];
                return MessageTile(
                  message: msg,
                  onDismiss: () =>
                      context.read<MessagesCubit>().dismiss(msg.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}