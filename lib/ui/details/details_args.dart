import 'package:flutter/foundation.dart';

import '../../domain/models/movie.dart';

@immutable
class DetailsArgs {
  const DetailsArgs({
    required this.movie,
    this.posterHeroTag,
    this.backdropHeroTag,
  });

  final Movie movie;
  final String? posterHeroTag;
  final String? backdropHeroTag;
}
