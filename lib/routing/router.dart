import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/about/widgets/about_screen.dart';
import '../ui/details/details_args.dart';
import '../ui/details/widgets/movie_details_screen.dart';
import '../ui/favorites/widgets/favorites_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/search/widgets/search_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/movie/:id',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: MovieDetailsScreen(
          movieId: int.parse(state.pathParameters['id']!),
          args: state.extra as DetailsArgs?,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);
