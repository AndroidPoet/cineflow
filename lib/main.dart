import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'routing/nav.dart';

void main() {
  if (kDebugMode) {
    navStack.addListener(
      () => debugPrint('STACK: ${navStack.keys.map((k) => k.runtimeType)}'),
    );
  }
  runApp(const ProviderScope(child: CineFlowApp()));
}
