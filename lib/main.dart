import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/tmdb_config.dart';
import 'routing/nav.dart';

void main() {
  assert(
    TmdbConfig.readAccessToken.isNotEmpty,
    'TMDB_TOKEN is empty. Run with --dart-define=TMDB_TOKEN=<your token>.',
  );
  if (kDebugMode) {
    navStack.addListener(
      () => debugPrint('STACK: ${navStack.keys.map((k) => k.runtimeType)}'),
    );
  }
  runApp(const ProviderScope(child: CineFlowApp()));
}
