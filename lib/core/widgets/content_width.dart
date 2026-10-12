import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Keeps a page's content at a readable width on wide screens; no effect on phones.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({super.key, required this.child, this.maxWidth = AppConstants.webContentMaxWidth});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      );
}
