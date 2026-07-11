import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/movie.dart';
import '../../domain/models/movie_details.dart';
import '../services/tmdb_api_service.dart';

final tmdbApiServiceProvider = Provider<TmdbApiService>(
  (ref) => TmdbApiService(),
);

final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => MovieRepository(api: ref.watch(tmdbApiServiceProvider)),
);

class MovieRepository {
  MovieRepository({required TmdbApiService api}) : _api = api;

  final TmdbApiService _api;

  Future<List<Movie>> trending() async =>
      _movieList(await _api.trendingMovies());

  Future<List<Movie>> nowPlaying({int page = 1}) async =>
      _movieList(await _api.nowPlayingMovies(page: page));

  Future<List<Movie>> popular({int page = 1}) async =>
      _movieList(await _api.popularMovies(page: page));

  Future<List<Movie>> topRated({int page = 1}) async =>
      _movieList(await _api.topRatedMovies(page: page));

  Future<List<Movie>> search(String query, {int page = 1}) async =>
      _movieList(await _api.searchMovies(query, page: page));

  Future<MovieDetails> details(int movieId) async =>
      MovieDetails.fromJson(await _api.movieDetails(movieId));

  List<Movie> _movieList(Map<String, dynamic> json) =>
      (json['results'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Movie.fromJson)
          .toList();
}
