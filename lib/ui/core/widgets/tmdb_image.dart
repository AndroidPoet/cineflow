import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

class TmdbImage extends StatelessWidget {
  const TmdbImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Widget image = url == null
        ? ColoredBox(
            color: scheme.surfaceContainerHighest,
            child: Icon(Icons.movie_outlined, color: scheme.outline),
          )
        : CachedNetworkImage(
            imageUrl: url!,
            fit: fit,
            placeholder: (context, url) =>
                ColoredBox(color: scheme.surfaceContainerHighest),
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: Icon(Icons.broken_image_outlined, color: scheme.outline),
            ),
          );
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
