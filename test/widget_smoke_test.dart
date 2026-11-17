import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallhaven_client/app.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';
import 'package:wallhaven_client/services/auto_changer.dart';
import 'package:wallhaven_client/services/downloader.dart';
import 'package:wallhaven_client/services/history_repository.dart';
import 'package:wallhaven_client/services/wallhaven_api.dart';
import 'package:wallhaven_client/services/wallpaper/wallpaper_io.dart';
import 'package:wallhaven_client/services/wallpaper/wallpaper_service.dart';
import 'package:wallhaven_client/state/app_state.dart';

/// Fake path_provider so AppState.load() works without platform channels.
class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async =>
      Directory.systemTemp.path;
}

/// Builds the whole app (all four tabs via IndexedStack) against mocked
/// plugins, validating wiring and UI compilation end to end.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  Future<Widget> buildApp() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    await state.load();
    final history = HistoryRepository(prefs);
    await history.load();
    final api = WallhavenApi(apiKeyProvider: () => state.apiKey);
    final wallpaper = createWallpaperService();
    final changer = AutoChanger(
      api: api,
      downloader: WallpaperDownloader(http.Client()),
      wallpaper: wallpaper,
      history: history,
      getOptions: () => state.options,
      getDownloadDir: () => state.downloadDir,
      getFit: () => state.fit,
      getMaxDownloads: () => state.maxDownloads,
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<HistoryRepository>.value(value: history),
        ChangeNotifierProvider<AutoChanger>.value(value: changer),
        Provider<WallhavenApi>.value(value: api),
        Provider<WallpaperDownloader>.value(
          value: WallpaperDownloader(http.Client()),
        ),
        Provider<WallpaperService>.value(value: wallpaper),
      ],
      child: const WallhavenApp(),
    );
  }

  testWidgets('every tab renders when activated', (tester) async {
    final app = await buildApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final l = await AppLocalizations.delegate.load(const Locale('en'));

    // Tab 0 (Auto) is active on launch. The app title lives in the native
    // window title bar now, not in an in-app AppBar.
    expect(find.text(l.autoSectionTitle), findsOneWidget);
    expect(find.text(l.startButton), findsOneWidget);

    // Tab 1: search configuration.
    await tester.tap(find.byIcon(Icons.manage_search_outlined));
    await tester.pumpAndSettle();
    expect(find.text(l.searchSectionTitle), findsOneWidget);
    expect(find.text(l.queryLabel), findsOneWidget);

    // Tab 2: history.
    await tester.tap(find.byIcon(Icons.history_outlined));
    await tester.pumpAndSettle();
    expect(find.text(l.historySectionTitle), findsOneWidget);
    expect(find.text(l.noHistory), findsOneWidget);

    // Tab 3: settings.
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text(l.apiKeyLabel), findsOneWidget);
    expect(find.text(l.intervalLabel), findsOneWidget);
    expect(find.text(l.downloadFolderLabel), findsOneWidget);
  });
}
