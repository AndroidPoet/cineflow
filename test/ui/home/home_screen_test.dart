import 'package:cineflow/domain/models/movie.dart';
import 'package:cineflow/ui/home/home_providers.dart';
import 'package:cineflow/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _movies = [
  Movie(id: 1, title: 'First Movie', overview: '', voteAverage: 7.5),
  Movie(id: 2, title: 'Second Movie', overview: '', voteAverage: 8.1),
];

void main() {
  Future<void> useTallSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('renders rails with loaded movies', (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trendingMoviesProvider.overrideWith((ref) => _movies),
          nowPlayingMoviesProvider.overrideWith((ref) => _movies),
          popularMoviesProvider.overrideWith((ref) => _movies),
          topRatedMoviesProvider.overrideWith((ref) => _movies),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Now playing'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top rated'), findsOneWidget);
    expect(find.text('First Movie'), findsWidgets);
  });

  testWidgets('shows retry when a rail fails', (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          trendingMoviesProvider.overrideWith((ref) => _movies),
          nowPlayingMoviesProvider.overrideWith(
            (ref) => throw Exception('network down'),
          ),
          popularMoviesProvider.overrideWith((ref) => _movies),
          topRatedMoviesProvider.overrideWith((ref) => _movies),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Could not load movies'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
