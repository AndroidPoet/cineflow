import 'package:cineflow/domain/models/movie.dart';
import 'package:cineflow/domain/models/movie_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movie.fromJson', () {
    test('parses a full TMDB payload', () {
      final movie = Movie.fromJson(const {
        'id': 603,
        'title': 'The Matrix',
        'overview': 'A computer hacker learns the truth.',
        'vote_average': 8.2,
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'release_date': '1999-03-30',
      });

      expect(movie.id, 603);
      expect(movie.title, 'The Matrix');
      expect(movie.voteAverage, 8.2);
      expect(movie.posterPath, '/poster.jpg');
      expect(movie.releaseYear, 1999);
      expect(movie.heroTag, 'poster-603');
    });

    test('tolerates missing optional fields', () {
      final movie = Movie.fromJson(const {'id': 1});

      expect(movie.title, '');
      expect(movie.posterPath, isNull);
      expect(movie.releaseDate, isNull);
      expect(movie.voteAverage, 0);
    });
  });

  group('MovieDetails.fromJson', () {
    test('parses appended credits, videos and similar', () {
      final details = MovieDetails.fromJson(const {
        'id': 603,
        'title': 'The Matrix',
        'runtime': 136,
        'tagline': 'Welcome to the Real World.',
        'genres': [
          {'id': 28, 'name': 'Action'},
          {'id': 878, 'name': 'Science Fiction'},
        ],
        'credits': {
          'cast': [
            {'id': 6384, 'name': 'Keanu Reeves', 'character': 'Neo'},
          ],
        },
        'videos': {
          'results': [
            {'site': 'YouTube', 'type': 'Trailer', 'key': 'abc123'},
          ],
        },
        'similar': {
          'results': [
            {'id': 604, 'title': 'The Matrix Reloaded'},
          ],
        },
      });

      expect(details.movie.id, 603);
      expect(details.runtimeMinutes, 136);
      expect(details.genres, ['Action', 'Science Fiction']);
      expect(details.cast.single.name, 'Keanu Reeves');
      expect(details.trailerYoutubeKey, 'abc123');
      expect(details.similar.single.id, 604);
    });

    test('tolerates missing appended sections', () {
      final details = MovieDetails.fromJson(const {'id': 1});

      expect(details.cast, isEmpty);
      expect(details.similar, isEmpty);
      expect(details.trailerYoutubeKey, isNull);
    });
  });
}
