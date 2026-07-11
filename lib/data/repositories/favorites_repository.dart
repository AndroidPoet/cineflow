import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/movie.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(),
);

class FavoritesRepository {
  FavoritesRepository({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const _key = 'favorite_movies';

  final SharedPreferencesAsync _prefs;

  Future<List<Movie>> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();
  }

  Future<void> save(List<Movie> movies) =>
      _prefs.setString(_key, jsonEncode([for (final m in movies) m.toJson()]));
}
