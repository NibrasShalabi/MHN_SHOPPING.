import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/messages/presentation/cubits/messages_cubit.dart';
import '../../features/messages/presentation/cubits/messages_state.dart';
import '../constants/app_strings.dart';
import 'badged_icon.dart';

/// The menu button, with the inbox count — the drawer is where messages live.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppStrings.menu,
      icon: BlocSelector<MessagesCubit, MessagesState, int>(
        selector: (s) => s.unreadCount,
        builder: (context, count) => BadgedIcon(icon: Icons.menu, count: count),
      ),
      onPressed: () => Scaffold.of(context).openEndDrawer(),
    );
  }
}
