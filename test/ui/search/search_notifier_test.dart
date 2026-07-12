import 'package:cineflow/data/repositories/movie_repository.dart';
import 'package:cineflow/data/services/tmdb_api_service.dart';
import 'package:cineflow/ui/search/search_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTmdbApiService extends TmdbApiService {
  int searchCalls = 0;

  @override
  Future<Map<String, dynamic>> searchMovies(String query, {int page = 1}) {
    searchCalls++;
    return Future.value({
      'page': page,
      'total_pages': 5,
      'results': [
        for (var i = 0; i < 20; i++)
          {'id': page * 100 + i, 'title': '$query $i'},
      ],
    });
  }
}

void main() {
  late _FakeTmdbApiService fakeApi;
  late ProviderContainer container;

  setUp(() {
    fakeApi = _FakeTmdbApiService();
    container = ProviderContainer(
      overrides: [tmdbApiServiceProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);
  });

  test('debounces queries and searches the last one', () async {
    final subscription = container.listen(searchProvider, (prev, next) {});
    addTearDown(subscription.close);
    await container.read(searchProvider.future);

    final notifier = container.read(searchProvider.notifier);
    notifier.setQuery('ma');
    notifier.setQuery('mat');
    notifier.setQuery('matrix');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(fakeApi.searchCalls, 1);
    final state = container.read(searchProvider).value!;
    expect(state.query, 'matrix');
    expect(state.movies, hasLength(20));
    expect(state.hasMore, isTrue);
  });

  test('loadMore appends the next page', () async {
    final subscription = container.listen(searchProvider, (prev, next) {});
    addTearDown(subscription.close);
    await container.read(searchProvider.future);

    final notifier = container.read(searchProvider.notifier);
    notifier.setQuery('matrix');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await notifier.loadMore();

    final state = container.read(searchProvider).value!;
    expect(state.movies, hasLength(40));
    expect(state.page, 2);
  });

  test('empty query resets to idle without calling the API', () async {
    final subscription = container.listen(searchProvider, (prev, next) {});
    addTearDown(subscription.close);
    await container.read(searchProvider.future);

    container.read(searchProvider.notifier).setQuery('   ');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(fakeApi.searchCalls, 0);
    expect(container.read(searchProvider).value!.query, isEmpty);
  });
}
