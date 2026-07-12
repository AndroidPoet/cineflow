import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/tmdb_config.dart';

class TmdbException implements Exception {
  const TmdbException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  String get userMessage => switch (statusCode) {
    0 => 'No internet connection.',
    401 => 'Authentication failed — check your TMDB token.',
    404 => 'That content could not be found.',
    408 => 'The request timed out. Check your connection.',
    >= 500 => 'TMDB is having trouble right now. Please try again.',
    _ => 'Something went wrong. Please try again.',
  };

  @override
  String toString() => 'TmdbException($statusCode): $message';
}

class TmdbApiService {
  TmdbApiService({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 15);

  final http.Client _client;
  final Duration _timeout;

  Future<Map<String, dynamic>> trendingMovies({String timeWindow = 'day'}) =>
      _get('/trending/movie/$timeWindow');

  Future<Map<String, dynamic>> nowPlayingMovies({int page = 1}) =>
      _get('/movie/now_playing', {'page': '$page'});

  Future<Map<String, dynamic>> popularMovies({int page = 1}) =>
      _get('/movie/popular', {'page': '$page'});

  Future<Map<String, dynamic>> topRatedMovies({int page = 1}) =>
      _get('/movie/top_rated', {'page': '$page'});

  Future<Map<String, dynamic>> searchMovies(String query, {int page = 1}) =>
      _get('/search/movie', {'query': query, 'page': '$page'});

  Future<Map<String, dynamic>> movieDetails(int movieId) =>
      _get('/movie/$movieId', {'append_to_response': 'credits,videos,similar'});

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse(
      '${TmdbConfig.apiBaseUrl}$path',
    ).replace(queryParameters: query);

    final http.Response response;
    try {
      response = await _client
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer ${TmdbConfig.readAccessToken}',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const TmdbException(408, 'Request timed out');
    } on http.ClientException catch (e) {
      throw TmdbException(0, e.message);
    }

    if (response.statusCode != 200) {
      throw TmdbException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
