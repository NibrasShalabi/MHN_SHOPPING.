import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'media_config.dart';

/// Every remote image in the app: resolves a bucket path through
/// MediaConfig and caches on disk, so a product seen once doesn't download
/// again. [thumb] picks the small copy (product cards, cart, orders).
class AppImage extends StatelessWidget {
  final String? path;
  final bool thumb;
  final BoxFit fit;

  /// Shown with no path, while loading and if the load fails.
  final Widget placeholder;

  const AppImage(this.path, {super.key, this.thumb = false, this.fit = BoxFit.cover, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p == null || p.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: thumb ? MediaConfig.thumbUrl(p) : MediaConfig.url(p),
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}
