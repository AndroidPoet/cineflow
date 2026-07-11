import 'package:flutter/foundation.dart';

import 'cast_member.dart';
import 'movie.dart';

@immutable
class MovieDetails {
  const MovieDetails({
    required this.movie,
    required this.genres,
    required this.cast,
    required this.similar,
    this.runtimeMinutes,
    this.tagline,
    this.trailerYoutubeKey,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    final credits = json['credits'] as Map<String, dynamic>? ?? const {};
    final videos = json['videos'] as Map<String, dynamic>? ?? const {};
    final similar = json['similar'] as Map<String, dynamic>? ?? const {};

    final trailer = (videos['results'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((v) => v['site'] == 'YouTube' && v['type'] == 'Trailer')
        .firstOrNull;

    return MovieDetails(
      movie: Movie.fromJson(json),
      genres: (json['genres'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map((g) => g['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      cast: (credits['cast'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .take(20)
          .map(CastMember.fromJson)
          .toList(),
      similar: (similar['results'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(Movie.fromJson)
          .toList(),
      runtimeMinutes: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      trailerYoutubeKey: trailer?['key'] as String?,
    );
  }

  final Movie movie;
  final List<String> genres;
  final List<CastMember> cast;
  final List<Movie> similar;
  final int? runtimeMinutes;
  final String? tagline;
  final String? trailerYoutubeKey;
}
