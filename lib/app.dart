import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';

import 'state/app_state.dart';
import 'ui/home_screen.dart';

class WallhavenApp extends StatelessWidget {
  const WallhavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final localeCode = state.localeCode;
    const seedColor = Color(0xFF6C5CE7);
    return MaterialApp(
      title: 'Wallhaven Client',
      locale: localeCode == 'system' ? null : Locale(localeCode),
      // Hand-built delegate list: the generated AppLocalizations still lists
      // the deprecated flutter_localizations delegates, but material_ui's
      // widgets look up *its own* MaterialLocalizations, so we must install
      // the material_ui/cupertino_ui ones.
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate, // from material_ui
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // from cupertino_ui
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
