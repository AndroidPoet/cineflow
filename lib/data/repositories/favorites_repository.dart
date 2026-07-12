import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/movie.dart';
import '../db/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(ref.watch(appDatabaseProvider)),
);

class FavoritesRepository {
  FavoritesRepository(this._db);

  final AppDatabase _db;

  Stream<List<Movie>> watchAll() {
    final query = _db.select(_db.favorites)
      ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]);
    return query.watch().map((rows) => rows.map(_toMovie).toList());
  }

  Future<bool> isFavorite(int id) async {
    final row = await (_db.select(
      _db.favorites,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null;
  }

  Future<void> toggle(Movie movie) async {
    if (await isFavorite(movie.id)) {
      await (_db.delete(
        _db.favorites,
      )..where((t) => t.id.equals(movie.id))).go();
    } else {
      await _db.into(_db.favorites).insert(_toRow(movie));
    }
  }

  FavoritesCompanion _toRow(Movie m) => FavoritesCompanion.insert(
    id: Value(m.id),
    title: m.title,
    overview: m.overview,
    voteAverage: m.voteAverage,
    posterPath: Value(m.posterPath),
    backdropPath: Value(m.backdropPath),
    releaseDate: Value(m.releaseDate),
  );

  Movie _toMovie(FavoriteRow r) => Movie(
    id: r.id,
    title: r.title,
    overview: r.overview,
    voteAverage: r.voteAverage,
    posterPath: r.posterPath,
    backdropPath: r.backdropPath,
    releaseDate: r.releaseDate,
  );
}
