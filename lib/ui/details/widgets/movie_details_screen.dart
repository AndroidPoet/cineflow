import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/tmdb_config.dart';
import '../../../domain/models/cast_member.dart';
import '../../../domain/models/movie.dart';
import '../../../domain/models/movie_details.dart';
import '../../core/widgets/movie_poster_card.dart';
import '../../core/widgets/tmdb_image.dart';
import '../../favorites/favorites_providers.dart';
import '../details_providers.dart';

class MovieDetailsScreen extends ConsumerWidget {
  const MovieDetailsScreen({
    super.key,
    required this.movieId,
    this.initialMovie,
    this.posterHeroTag,
    this.backdropHeroTag,
  });

  final int movieId;
  final Movie? initialMovie;
  final String? posterHeroTag;
  final String? backdropHeroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(movieDetailsProvider(movieId));

    final body = details.when(
      data: (details) => _DetailsBody(
        movie: details.movie,
        details: details,
        posterHeroTag: posterHeroTag,
        backdropHeroTag: backdropHeroTag,
      ),
      error: (error, stackTrace) => _DetailsError(
        onRetry: () => ref.invalidate(movieDetailsProvider(movieId)),
      ),
      loading: () => initialMovie == null
          ? const Center(child: CircularProgressIndicator())
          : _DetailsBody(
              movie: initialMovie!,
              details: null,
              posterHeroTag: posterHeroTag,
              backdropHeroTag: backdropHeroTag,
            ),
    );

    final movie = details.value?.movie ?? initialMovie;
    final posterUrl = TmdbConfig.posterUrl(movie?.posterPath);
    if (posterUrl == null) return Scaffold(body: body);

    final scheme = ref.watch(posterColorSchemeProvider(posterUrl));
    return Theme(
      data: scheme.value == null
          ? Theme.of(context)
          : Theme.of(context).copyWith(colorScheme: scheme.value),
      child: Scaffold(body: body),
    );
  }
}

class _DetailsBody extends ConsumerWidget {
  const _DetailsBody({
    required this.movie,
    required this.details,
    this.posterHeroTag,
    this.backdropHeroTag,
  });

  final Movie movie;
  final MovieDetails? details;
  final String? posterHeroTag;
  final String? backdropHeroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favorites = ref.watch(favoritesProvider).value ?? const <Movie>[];
    final isFavorite = favorites.any((m) => m.id == movie.id);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          actions: [
            IconButton(
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(movie),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_outline,
                color: isFavorite ? theme.colorScheme.primary : null,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: backdropHeroTag ?? 'backdrop-detail-${movie.id}',
                  child: TmdbImage(
                    url: TmdbConfig.backdropUrl(movie.backdropPath),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderRow(
                  movie: movie,
                  details: details,
                  posterHeroTag: posterHeroTag,
                ),
                const SizedBox(height: 20),
                if (details == null)
                  const _SkeletonRest()
                else
                  _LoadedRest(details: details!),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.movie,
    required this.details,
    this.posterHeroTag,
  });

  final Movie movie;
  final MovieDetails? details;
  final String? posterHeroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Hero(
              tag: posterHeroTag ?? 'poster-detail-${movie.id}',
              child: TmdbImage(
                url: TmdbConfig.posterUrl(movie.posterPath),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                [
                  if (movie.releaseYear != null) '${movie.releaseYear}',
                  if (details?.runtimeMinutes != null)
                    '${details!.runtimeMinutes} min',
                  '★ ${movie.voteAverage.toStringAsFixed(1)}',
                ].join('  ·  '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (details != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final genre in details!.genres.take(3))
                      Chip(
                        label: Text(genre),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonRest extends StatelessWidget {
  const _SkeletonRest();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 4; i++) ...[
            const Bone.text(words: 12),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          const Bone.text(words: 2),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                const Bone.circle(size: 72),
                const SizedBox(width: 20),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadedRest extends StatelessWidget {
  const _LoadedRest({required this.details});

  final MovieDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movie = details.movie;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (details.tagline case final tagline? when tagline.isNotEmpty) ...[
          Text(
            tagline,
            style: theme.textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(movie.overview, style: theme.textTheme.bodyLarge),
        if (details.trailerYoutubeKey case final key?) ...[
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => launchUrl(
              Uri.parse('https://www.youtube.com/watch?v=$key'),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Watch trailer'),
          ),
        ],
        if (details.cast.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Cast', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: details.cast.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _CastTile(member: details.cast[index]),
            ),
          ),
        ],
        if (details.similar.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('More like this', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: details.similar.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => MoviePosterCard(
                movie: details.similar[index],
                heroPrefix: 'similar-${movie.id}',
                width: 130,
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 72,
            child: TmdbImage(
              url: TmdbConfig.profileUrl(member.profilePath),
              borderRadius: BorderRadius.circular(36),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Could not load movie'),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
