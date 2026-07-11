import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/movie_repository.dart';
import '../../domain/models/movie.dart';

final trendingMoviesProvider = FutureProvider.autoDispose<List<Movie>>(
  (ref) => ref.watch(movieRepositoryProvider).trending(),
);

final nowPlayingMoviesProvider = FutureProvider.autoDispose<List<Movie>>(
  (ref) => ref.watch(movieRepositoryProvider).nowPlaying(),
);

final popularMoviesProvider = FutureProvider.autoDispose<List<Movie>>(
  (ref) => ref.watch(movieRepositoryProvider).popular(),
);

final topRatedMoviesProvider = FutureProvider.autoDispose<List<Movie>>(
  (ref) => ref.watch(movieRepositoryProvider).topRated(),
);
