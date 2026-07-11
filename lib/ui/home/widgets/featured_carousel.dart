import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../config/tmdb_config.dart';
import '../../../domain/models/movie.dart';
import '../../core/widgets/tmdb_image.dart';
import '../../details/details_args.dart';
import '../home_providers.dart';

class FeaturedCarousel extends ConsumerStatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  ConsumerState<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends ConsumerState<FeaturedCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trending = ref.watch(trendingMoviesProvider);
    return SizedBox(
      height: 440,
      child: trending.when(
        data: (movies) {
          final featured = movies.take(6).toList();
          if (featured.isEmpty) return const SizedBox.shrink();
          return Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: featured.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) =>
                    _FeaturedPage(movie: featured[index]),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < featured.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: i == _page
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: .3),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => const SizedBox.shrink(),
        loading: () => const Skeletonizer(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Bone(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedPage extends StatelessWidget {
  const _FeaturedPage({required this.movie});

  final Movie movie;

  String get _heroTag => 'featured-${movie.id}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push(
        '/movie/${movie.id}',
        extra: DetailsArgs(movie: movie, backdropHeroTag: _heroTag),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: _heroTag,
            child: TmdbImage(
              url: TmdbConfig.backdropUrl(
                movie.backdropPath ?? movie.posterPath,
                size: 'w780',
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [.4, 1],
                colors: [
                  Colors.transparent,
                  theme.scaffoldBackgroundColor.withValues(alpha: .95),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    if (movie.releaseYear != null) '${movie.releaseYear}',
                    '★ ${movie.voteAverage.toStringAsFixed(1)}',
                  ].join('  ·  '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: .2),
          ),
        ],
      ),
    );
  }
}
