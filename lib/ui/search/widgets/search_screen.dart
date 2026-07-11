import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/widgets/movie_poster_card.dart';
import '../search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchProvider);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search movies…',
            border: InputBorder.none,
          ),
          onChanged: (query) =>
              ref.read(searchProvider.notifier).setQuery(query),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _controller.clear();
              ref.read(searchProvider.notifier).setQuery('');
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: results.when(
        data: (state) {
          if (state.query.isEmpty) {
            return const _CenteredHint(
              icon: Icons.search,
              message: 'Find your next favorite movie',
            );
          }
          if (state.movies.isEmpty) {
            return _CenteredHint(
              icon: Icons.movie_filter_outlined,
              message: 'No results for “${state.query}”',
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >
                  notification.metrics.maxScrollExtent - 400) {
                ref.read(searchProvider.notifier).loadMore();
              }
              return false;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.52,
              ),
              itemCount: state.movies.length,
              itemBuilder: (context, index) => MoviePosterCard(
                movie: state.movies[index],
                heroPrefix: 'search',
              ),
            ),
          );
        },
        error: (error, stackTrace) => _CenteredHint(
          icon: Icons.wifi_off,
          message: 'Search failed — check your connection',
          action: FilledButton.tonal(
            onPressed: () =>
                ref.read(searchProvider.notifier).setQuery(_controller.text),
            child: const Text('Retry'),
          ),
        ),
        loading: () => Skeletonizer(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.52,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Bone(
                    width: double.infinity,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                SizedBox(height: 8),
                Bone.text(words: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenteredHint extends StatelessWidget {
  const _CenteredHint({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
