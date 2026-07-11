import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/favorites_repository.dart';
import '../../domain/models/movie.dart';

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<Movie>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<Movie>> {
  @override
  Future<List<Movie>> build() => ref.watch(favoritesRepositoryProvider).load();

  Future<void> toggle(Movie movie) async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => const <Movie>[],
    };
    final updated = current.any((m) => m.id == movie.id)
        ? current.where((m) => m.id != movie.id).toList()
        : [...current, movie];
    state = AsyncData(updated);
    await ref.read(favoritesRepositoryProvider).save(updated);
  }
}
