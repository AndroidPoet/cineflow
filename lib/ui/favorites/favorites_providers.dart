import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/favorites_repository.dart';
import '../../domain/models/movie.dart';

final favoritesProvider =
    StreamNotifierProvider<FavoritesNotifier, List<Movie>>(
      FavoritesNotifier.new,
    );

class FavoritesNotifier extends StreamNotifier<List<Movie>> {
  @override
  Stream<List<Movie>> build() =>
      ref.watch(favoritesRepositoryProvider).watchAll();

  Future<void> toggle(Movie movie) =>
      ref.read(favoritesRepositoryProvider).toggle(movie);
}
