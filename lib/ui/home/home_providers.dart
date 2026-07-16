import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/movie_repository.dart';
import '../../domain/models/movie.dart';

enum MovieCategory {
  trending,
  nowPlaying,
  popular,
  topRated;

  String get label => switch (this) {
    MovieCategory.trending => 'Trending',
    MovieCategory.nowPlaying => 'Now playing',
    MovieCategory.popular => 'Popular',
    MovieCategory.topRated => 'Top rated',
  };
}

final moviesByCategoryProvider = FutureProvider.autoDispose
    .family<List<Movie>, MovieCategory>((ref, category) {
      final repository = ref.watch(movieRepositoryProvider);
      return switch (category) {
        MovieCategory.trending => repository.trending(),
        MovieCategory.nowPlaying => repository.nowPlaying(),
        MovieCategory.popular => repository.popular(),
        MovieCategory.topRated => repository.topRated(),
      };
    });
