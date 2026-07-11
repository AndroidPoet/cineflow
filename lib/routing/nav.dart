import 'package:back_stack/back_stack.dart';

import '../domain/models/movie.dart';
import '../ui/about/widgets/about_screen.dart';
import '../ui/details/widgets/movie_details_screen.dart';
import '../ui/favorites/widgets/favorites_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/search/widgets/search_screen.dart';

sealed class AppKey extends NavKey {
  const AppKey();
}

class HomeKey extends AppKey {
  const HomeKey();
}

class MovieDetailsKey extends AppKey {
  const MovieDetailsKey(
    this.movieId, {
    this.movie,
    this.posterHeroTag,
    this.backdropHeroTag,
  });

  final int movieId;
  final Movie? movie;
  final String? posterHeroTag;
  final String? backdropHeroTag;
}

class SearchKey extends AppKey {
  const SearchKey();
}

class FavoritesKey extends AppKey {
  const FavoritesKey();
}

class AboutKey extends AppKey {
  const AboutKey();
}

final navStack = NavStack<AppKey>.of(const HomeKey());

final navEntries = NavEntries<AppKey>()
  ..on<HomeKey>((context, key) => const HomeScreen())
  ..on<MovieDetailsKey>(
    (context, key) => MovieDetailsScreen(
      movieId: key.movieId,
      initialMovie: key.movie,
      posterHeroTag: key.posterHeroTag,
      backdropHeroTag: key.backdropHeroTag,
    ),
    page: (context, key, child, pageKey) =>
        TransitionPage<void>.fade(key: pageKey, child: child),
  )
  ..on<SearchKey>((context, key) => const SearchScreen())
  ..on<FavoritesKey>((context, key) => const FavoritesScreen())
  ..on<AboutKey>((context, key) => const AboutScreen());

final navLinks = NavLinks<AppKey>()
  ..on<HomeKey>('/', decode: (m) => const HomeKey())
  ..on<MovieDetailsKey>(
    '/movie/:id',
    decode: (m) => MovieDetailsKey(m.integer('id')!),
    encode: (key) => {'id': key.movieId},
    parents: (key) => const [HomeKey()],
  )
  ..on<SearchKey>(
    '/search',
    decode: (m) => const SearchKey(),
    parents: (key) => const [HomeKey()],
  )
  ..on<FavoritesKey>(
    '/favorites',
    decode: (m) => const FavoritesKey(),
    parents: (key) => const [HomeKey()],
  )
  ..on<AboutKey>(
    '/about',
    decode: (m) => const AboutKey(),
    parents: (key) => const [HomeKey()],
  )
  ..notFound((uri) => const [HomeKey()]);
