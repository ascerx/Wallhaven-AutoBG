import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'utils/app_args.dart';
import 'services/auto_changer.dart';
import 'services/downloader.dart';
import 'services/history_repository.dart';
import 'services/wallhaven_api.dart';
import 'services/wallpaper/wallpaper_io.dart';
import 'services/wallpaper/wallpaper_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Window management: hide to tray on close, and optionally start hidden
  // in the tray (used by the "run at startup" entry via `--hidden`).
  // Wrapped so a broken plugin (e.g. missing VC++ runtime on the target
  // machine) can't stop the app from starting.
  final startHidden = shouldStartHidden();
  try {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(title: 'Wallhaven Client'),
      () async {
        if (!startHidden) {
          await windowManager.show();
          await windowManager.focus();
        }
      },
    );
  } on Exception {
    // Run as a plain window without window_manager.
  }

  final prefs = await SharedPreferences.getInstance();

  final state = AppState(prefs);
  await state.load();

  final history = HistoryRepository(prefs);
  await history.load();

  final api = WallhavenApi(apiKeyProvider: () => state.apiKey);
  final downloader = WallpaperDownloader(http.Client());
  final wallpaperService = createWallpaperService();

  final changer = AutoChanger(
    api: api,
    downloader: downloader,
    wallpaper: wallpaperService,
    history: history,
    getOptions: () => state.options,
    getDownloadDir: () => state.downloadDir,
    getFit: () => state.fit,
    getMaxDownloads: () => state.maxDownloads,
    appState: state,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: state),
        ChangeNotifierProvider<HistoryRepository>.value(value: history),
        ChangeNotifierProvider<AutoChanger>.value(value: changer),
        Provider<WallhavenApi>.value(value: api),
        Provider<WallpaperDownloader>.value(value: downloader),
        Provider<WallpaperService>.value(value: wallpaperService),
      ],
      child: const WallhavenApp(),
    ),
  );
}
