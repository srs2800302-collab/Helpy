import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/localization/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class FixiApp extends StatelessWidget {
  const FixiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();

    return MaterialApp.router(
      title: 'Fixi',
      theme: buildAppTheme(),
      routerConfig: router,
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
        Locale('th'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
