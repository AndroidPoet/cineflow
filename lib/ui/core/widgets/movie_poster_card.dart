import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/tmdb_config.dart';
import '../../../domain/models/movie.dart';
import '../../details/details_args.dart';
import 'tmdb_image.dart';

class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({
    super.key,
    required this.movie,
    required this.heroPrefix,
    this.width,
  });

  final Movie movie;
  final String heroPrefix;
  final double? width;

  String get _heroTag => '$heroPrefix-poster-${movie.id}';

  @override
  Widget build(BuildContext context) {
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Hero(
              tag: _heroTag,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(
                    '/movie/${movie.id}',
                    extra: DetailsArgs(movie: movie, posterHeroTag: _heroTag),
                  ),
                  child: TmdbImage(
                    url: TmdbConfig.posterUrl(movie.posterPath),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
    return width == null ? card : SizedBox(width: width, child: card);
  }
}
