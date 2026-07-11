import 'package:cineflow/data/repositories/favorites_repository.dart';
import 'package:cineflow/domain/models/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('save and load round-trips movies', () async {
    final repository = FavoritesRepository();
    const movie = Movie(
      id: 603,
      title: 'The Matrix',
      overview: 'A hacker learns the truth.',
      voteAverage: 8.2,
      posterPath: '/poster.jpg',
    );

    await repository.save(const [movie]);
    final loaded = await repository.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 603);
    expect(loaded.single.title, 'The Matrix');
    expect(loaded.single.posterPath, '/poster.jpg');
  });

  test('load returns empty list when nothing saved', () async {
    final repository = FavoritesRepository();
    expect(await repository.load(), isEmpty);
  });
}
