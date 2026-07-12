import 'package:cineflow/data/db/app_database.dart';
import 'package:cineflow/data/repositories/favorites_repository.dart';
import 'package:cineflow/domain/models/movie.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FavoritesRepository repository;

  const movie = Movie(
    id: 603,
    title: 'The Matrix',
    overview: 'A hacker learns the truth.',
    voteAverage: 8.2,
    posterPath: '/poster.jpg',
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = FavoritesRepository(db);
  });

  tearDown(() => db.close());

  test('watchAll starts empty', () async {
    expect(await repository.watchAll().first, isEmpty);
  });

  test('toggle adds a movie', () async {
    await repository.toggle(movie);

    expect(await repository.isFavorite(603), isTrue);
    final saved = await repository.watchAll().first;
    expect(saved, hasLength(1));
    expect(saved.single.id, 603);
    expect(saved.single.title, 'The Matrix');
    expect(saved.single.posterPath, '/poster.jpg');
  });

  test('toggle twice removes the movie', () async {
    await repository.toggle(movie);
    await repository.toggle(movie);

    expect(await repository.isFavorite(603), isFalse);
    expect(await repository.watchAll().first, isEmpty);
  });

  test('watchAll emits on change', () async {
    final emissions = <int>[];
    final sub = repository.watchAll().listen((m) => emissions.add(m.length));

    await repository.toggle(movie);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await sub.cancel();
    expect(emissions, containsAllInOrder([0, 1]));
  });
}
