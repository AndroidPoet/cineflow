import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../domain/models/movie.dart';
import '../../core/widgets/movie_poster_card.dart';
import '../home_providers.dart';

class MovieRail extends ConsumerWidget {
  const MovieRail({super.key, required this.category});

  final MovieCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(moviesByCategoryProvider(category));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            category.label,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 260,
          child: movies.when(
            data: (movies) => _RailList(
              movies: movies,
              heroPrefix: category.name,
              animate: true,
            ),
            error: (error, stackTrace) => _RailError(
              onRetry: () => ref.invalidate(moviesByCategoryProvider(category)),
            ),
            loading: () => Skeletonizer(
              child: _RailList(
                movies: List.filled(5, _placeholderMovie),
                heroPrefix: '${category.name}-skeleton',
                animate: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _placeholderMovie = Movie(
  id: 0,
  title: 'Placeholder title',
  overview: '',
  voteAverage: 0,
);

class _RailList extends StatelessWidget {
  const _RailList({
    required this.movies,
    required this.heroPrefix,
    required this.animate,
  });

  final List<Movie> movies;
  final String heroPrefix;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: movies.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final card = MoviePosterCard(
          movie: movies[index],
          heroPrefix: heroPrefix,
          width: 140,
        );
        if (!animate) return card;
        return card
            .animate()
            .fadeIn(duration: 350.ms, delay: (40 * index.clamp(0, 8)).ms)
            .slideX(begin: .08, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _RailError extends StatelessWidget {
  const _RailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Could not load movies'),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
