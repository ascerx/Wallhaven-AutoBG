import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/auto_changer.dart';
import '../services/hotkey_service.dart';
import '../state/app_state.dart';
import 'screens/auto_screen.dart';
import 'screens/history_screen.dart';
import 'screens/search_config_screen.dart';
import 'screens/settings_screen.dart';

class NavDestination {
  const NavDestination(this.icon, this.selectedIcon, this.label);
  final Widget icon;
  final Widget selectedIcon;
  final String label;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Optional auto-start when the app opens.
    final state = context.read<AppState>();
    final changer = context.read<AutoChanger>();
    // Restore the last applied wallpaper after a process restart (some
    // Android environments recreate the activity on wallpaper changes).
    if (changer.currentPath == null && state.lastAppliedPath.isNotEmpty) {
      final file = File(state.lastAppliedPath);
      if (file.existsSync()) {
        changer.currentPath = state.lastAppliedPath;
        changer.currentId = state.lastAppliedId;
      }
    }
    // Resume the rotation if it was active before the restart. No immediate
    // change: the wallpaper was already applied.
    if (state.rotationActive && !changer.isRunning) {
      changer.start(
        interval: Duration(minutes: state.intervalMinutes),
        resume: true,
      );
    } else if (state.autoStart && !changer.isRunning) {
      changer.start(interval: Duration(minutes: state.intervalMinutes));
    }
    // Optional global hotkey (desktop only).
    if (state.hotkeyEnabled && !Platform.isAndroid) {
      HotkeyService.register(changer);
    }
  }

  static const List<Widget> _screens = [
    AutoScreen(),
    SearchConfigScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final destinations = [
      NavDestination(
        const Icon(Icons.auto_awesome_outlined),
        const Icon(Icons.auto_awesome),
        l.tabAuto,
      ),
      NavDestination(
        const Icon(Icons.manage_search_outlined),
        const Icon(Icons.manage_search),
        l.tabSearch,
      ),
      NavDestination(
        const Icon(Icons.history_outlined),
        const Icon(Icons.history),
        l.tabHistory,
      ),
      NavDestination(
        const Icon(Icons.settings_outlined),
        const Icon(Icons.settings),
        l.tabSettings,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final extended = constraints.maxWidth >= 900;

        final body = wide
            ? Row(
                children: [
                  ScrollableNavigationRail(
                    extended: extended,
                    index: _index,
                    destinations: destinations,
                    onSelected: (i) => setState(() => _index = i),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: IndexedStack(index: _index, children: _screens),
                  ),
                ],
              )
            : IndexedStack(index: _index, children: _screens);

        return Scaffold(
          body: SafeArea(child: body),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: [
                    for (final d in destinations)
                      NavigationDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: d.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class ScrollableNavigationRail extends StatelessWidget {
  const ScrollableNavigationRail({
    super.key,
    required this.extended,
    required this.index,
    required this.destinations,
    required this.onSelected,
  });

  final bool extended;
  final int index;
  final List<NavDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: onSelected,
      extended: extended,
      minExtendedWidth: 200,
      labelType: extended ? null : NavigationRailLabelType.all,
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: d.icon,
            selectedIcon: d.selectedIcon,
            label: Text(d.label),
          ),
      ],
    );
  }
}
