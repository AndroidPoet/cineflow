import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/movie_repository.dart';
import '../../domain/models/movie.dart';

@immutable
class SearchState {
  const SearchState({
    required this.query,
    required this.movies,
    required this.page,
    required this.hasMore,
  });

  static const idle = SearchState(
    query: '',
    movies: [],
    page: 1,
    hasMore: false,
  );

  final String query;
  final List<Movie> movies;
  final int page;
  final bool hasMore;
}

final searchProvider =
    AsyncNotifierProvider.autoDispose<SearchNotifier, SearchState>(
      SearchNotifier.new,
    );

class SearchNotifier extends AsyncNotifier<SearchState> {
  Timer? _debounce;
  bool _loadingMore = false;

  @override
  Future<SearchState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    return SearchState.idle;
  }

  void setQuery(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const AsyncData(SearchState.idle);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _search(trimmed),
    );
  }

  Future<void> _search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(movieRepositoryProvider).search(query);
      return SearchState(
        query: query,
        movies: result.movies,
        page: result.page,
        hasMore: result.hasMore,
      );
    });
  }

  Future<void> loadMore() async {
    if (_loadingMore) return;
    if (state case AsyncData(:final value) when value.hasMore) {
      _loadingMore = true;
      try {
        final next = await ref
            .read(movieRepositoryProvider)
            .search(value.query, page: value.page + 1);
        state = AsyncData(
          SearchState(
            query: value.query,
            movies: [...value.movies, ...next.movies],
            page: next.page,
            hasMore: next.hasMore,
          ),
        );
      } on Exception {
        // keep the loaded pages; the next scroll retries
      } finally {
        _loadingMore = false;
      }
    }
  }
}
