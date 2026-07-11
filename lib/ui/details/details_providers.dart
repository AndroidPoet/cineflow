import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/movie_repository.dart';
import '../../domain/models/movie_details.dart';

final movieDetailsProvider = FutureProvider.autoDispose
    .family<MovieDetails, int>(
      (ref, movieId) => ref.watch(movieRepositoryProvider).details(movieId),
    );

final posterColorSchemeProvider = FutureProvider.autoDispose
    .family<ColorScheme, String>(
      (ref, posterUrl) => ColorScheme.fromImageProvider(
        provider: CachedNetworkImageProvider(posterUrl),
        brightness: Brightness.dark,
      ),
    );
