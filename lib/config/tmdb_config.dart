abstract final class TmdbConfig {
  // api.tmdb.org is TMDB's official alias for api.themoviedb.org, whose DNS
  // is poisoned by some ISPs (notably in India).
  static const apiBaseUrl = 'https://api.tmdb.org/3';
  static const imageBaseUrl = 'https://image.tmdb.org/t/p';

  static const readAccessToken = String.fromEnvironment('TMDB_TOKEN');

  static const posterSize = 'w500';
  static const backdropSize = 'w1280';
  static const profileSize = 'w185';

  static String? posterUrl(String? path, {String size = posterSize}) =>
      path == null ? null : '$imageBaseUrl/$size$path';

  static String? backdropUrl(String? path, {String size = backdropSize}) =>
      path == null ? null : '$imageBaseUrl/$size$path';

  static String? profileUrl(String? path, {String size = profileSize}) =>
      path == null ? null : '$imageBaseUrl/$size$path';
}
