import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/tmdb_config.dart';

class TmdbException implements Exception {
  const TmdbException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'TmdbException($statusCode): $message';
}

class TmdbApiService {
  TmdbApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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
    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${TmdbConfig.readAccessToken}',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw TmdbException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
