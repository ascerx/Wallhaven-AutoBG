import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:system_tray/system_tray.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

import 'services/auto_changer.dart';
import 'state/app_state.dart';
import 'ui/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class WallhavenApp extends StatefulWidget {
  const WallhavenApp({super.key});

  @override
  State<WallhavenApp> createState() => _WallhavenAppState();
}

class _WallhavenAppState extends State<WallhavenApp> with WindowListener {
  SystemTray? _tray;
  bool _trayReady = false;
  String? _menuLocale;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _setupTray();
  }

  /// Hides to the system tray instead of closing, so the wallpaper rotation
  /// keeps running in the background. If the tray is unavailable (tests,
  /// some Linux setups) the window closes normally.
  @override
  void onWindowClose() async {
    if (_trayReady) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }

  @override
  void onWindowFocus() {
    // Required when starting hidden: repaint once the window is focused.
    if (mounted) setState(() {});
  }

  Future<void> _setupTray() async {
    try {
      final tray = SystemTray();
      await tray.initSystemTray(
        title: 'Wallhaven Client',
        iconPath:
            Platform.isWindows ? 'assets/icon.ico' : 'assets/icon.png',
      );
      _tray = tray;
      _trayReady = true;
      await windowManager.setPreventClose(true);
      tray.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick) {
          windowManager.show();
          windowManager.focus();
        } else if (eventName == kSystemTrayEventRightClick) {
          tray.popUpContextMenu();
        }
      });
      _refreshMenu();
    } on Exception {
      // Tray unavailable: keep normal window behaviour.
    }
  }

  void _refreshMenu() {
    final context = navigatorKey.currentContext;
    if (!_trayReady || context == null) return;
    final l = AppLocalizations.of(context)!;
    final changer = context.read<AutoChanger>();
    _menuLocale = Localizations.localeOf(context).toString();

    final menu = Menu();
    menu.buildFrom([
      MenuItemLabel(
        label: l.trayShow,
        onClicked: (item) {
          windowManager.show();
          windowManager.focus();
        },
      ),
      MenuItemLabel(
        label: l.changeNowButton,
        onClicked: (item) => changer.changeNow(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: l.trayExit,
        onClicked: (item) async {
          changer.stop();
          await windowManager.destroy();
        },
      ),
    ]);
    _tray?.setContextMenu(menu);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.maybeLocaleOf(context);
    if (locale != null &&
        _menuLocale != null &&
        _menuLocale != locale.toString()) {
      _refreshMenu();
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final localeCode = state.localeCode;
    const seedColor = Color(0xFF6C5CE7);
    return MaterialApp(
      navigatorKey: navigatorKey,
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
