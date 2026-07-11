import 'package:back_stack/back_stack.dart';
import 'package:flutter/material.dart';

import 'routing/nav.dart';
import 'ui/core/themes/app_theme.dart';

class CineFlowApp extends StatelessWidget {
  const CineFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BackStackApp<AppKey>(
      title: 'CineFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      stack: navStack,
      entries: navEntries,
      links: navLinks,
    );
  }
}
