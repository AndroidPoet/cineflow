import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routing/nav.dart';
import '../home_providers.dart';
import 'featured_carousel.dart';
import 'movie_rail.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trendingMoviesProvider);
          ref.invalidate(nowPlayingMoviesProvider);
          ref.invalidate(popularMoviesProvider);
          ref.invalidate(topRatedMoviesProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                const FeaturedCarousel(),
                Positioned(
                  left: 16,
                  right: 8,
                  top: MediaQuery.paddingOf(context).top + 8,
                  child: Row(
                    children: [
                      Text(
                        'CineFlow',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => navStack.push(const SearchKey()),
                        icon: const Icon(Icons.search),
                      ),
                      IconButton(
                        onPressed: () => navStack.push(const FavoritesKey()),
                        icon: const Icon(Icons.favorite_outline),
                      ),
                      IconButton(
                        onPressed: () => navStack.push(const AboutKey()),
                        icon: const Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            MovieRail(
              title: 'Now playing',
              provider: nowPlayingMoviesProvider,
              heroPrefix: 'now',
            ),
            MovieRail(
              title: 'Popular',
              provider: popularMoviesProvider,
              heroPrefix: 'popular',
            ),
            MovieRail(
              title: 'Top rated',
              provider: topRatedMoviesProvider,
              heroPrefix: 'top',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
