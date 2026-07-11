import 'package:flutter/foundation.dart';

@immutable
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    overview: json['overview'] as String? ?? '',
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    posterPath: json['poster_path'] as String?,
    backdropPath: json['backdrop_path'] as String?,
    releaseDate: DateTime.tryParse(json['release_date'] as String? ?? ''),
  );

  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'overview': overview,
    'vote_average': voteAverage,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'release_date': releaseDate?.toIso8601String(),
  };

  String get heroTag => 'poster-$id';

  int? get releaseYear => releaseDate?.year;

  @override
  bool operator ==(Object other) => other is Movie && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
