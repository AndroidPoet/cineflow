import 'package:flutter/material.dart';

import 'routing/router.dart';
import 'ui/core/themes/app_theme.dart';

class CineFlowApp extends StatelessWidget {
  const CineFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CineFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
