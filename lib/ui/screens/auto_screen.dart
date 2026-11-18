import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/search_options.dart';
import '../../services/auto_changer.dart';
import '../../services/wallpaper/wallpaper_android.dart';
import '../../services/wallpaper/wallpaper_service.dart';
import '../../state/app_state.dart';
import '../widgets/ad_banner.dart';
import '../widgets/common.dart';

/// Main screen: start/stop the wallpaper rotation and see what is applied.
class AutoScreen extends StatefulWidget {
  const AutoScreen({super.key});

  @override
  State<AutoScreen> createState() => _AutoScreenState();
}

class _AutoScreenState extends State<AutoScreen> {
  Timer? _ticker;

  bool get _isAndroid => Platform.isAndroid;

  /// Android: the rotation runs in the native foreground service, so it
  /// keeps working with the app closed.
  Future<void> _startAndroid(BuildContext context) async {
    final state = context.read<AppState>();
    final changer = context.read<AutoChanger>();
    final service = context.read<WallpaperService>();
    if (service is AndroidWallpaperService) {
      await service.startBackgroundService(
        intervalMinutes: state.intervalMinutes,
        config: state.options.toJson(),
      );
    }
    changer.markExternalRunning();
  }

  Future<void> _stopAndroid(BuildContext context) async {
    final changer = context.read<AutoChanger>();
    final service = context.read<WallpaperService>();
    if (service is AndroidWallpaperService) {
      await service.stopBackgroundService();
    }
    changer.markExternalStopped();
  }

  @override
  void initState() {
    super.initState();
    // Ticks every second so the countdown stays fresh.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatRemaining(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final changer = context.watch<AutoChanger>();
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;

    final remaining = changer.nextChangeAt?.difference(DateTime.now());

    return ListView(
      children: [
        SectionCard(
          title: l.autoSectionTitle,
          trailing: Chip(
            avatar: Icon(
              changer.isRunning ? Icons.play_arrow : Icons.stop,
              size: 18,
            ),
            label: Text(changer.isRunning ? l.statusRunning : l.statusStopped),
            backgroundColor: changer.isRunning
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.intervalSummary(state.intervalMinutes)),
              if (changer.isRunning && remaining != null) ...[
                const SizedBox(height: 4),
                Text(
                  l.nextChangeIn(
                    remaining.isNegative
                        ? '00:00'
                        : _formatRemaining(remaining),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (_isAndroid)
                    changer.isRunning
                        ? FilledButton.tonalIcon(
                            onPressed: () => _stopAndroid(context),
                            icon: const Icon(Icons.stop),
                            label: Text(l.stopButton),
                          )
                        : FilledButton.icon(
                            onPressed: () => _startAndroid(context),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l.startButton),
                          )
                  else ...[
                    changer.isRunning
                        ? FilledButton.tonalIcon(
                            onPressed: changer.stop,
                            icon: const Icon(Icons.stop),
                            label: Text(l.stopButton),
                          )
                        : FilledButton.icon(
                            onPressed: () => changer.start(
                              interval:
                                  Duration(minutes: state.intervalMinutes),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l.startButton),
                          ),
                  ],
                  OutlinedButton.icon(
                    onPressed: changer.changeNow,
                    icon: const Icon(Icons.wallpaper),
                    label: Text(l.changeNowButton),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: state.autoStart,
                onChanged: (value) => state.setAutoStart(value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(l.autoStartOnLaunch),
              ),
            ],
          ),
        ),
        SectionCard(
          title: l.currentWallpaper,
          child: SizedBox(
            height: 280,
            width: double.infinity,
            child: changer.currentPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(changer.currentPath!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 48),
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wallpaper, size: 48),
                        const SizedBox(height: 8),
                        Text(l.noWallpaperYet),
                      ],
                    ),
                  ),
          ),
        ),
        if (changer.lastError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.lastError(changer.lastError!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (Platform.isAndroid) ...[
          // Hidden while NSFW content can be displayed (AdMob policy).
          AdBanner(nsfwActive: state.options.purity.contains(Purity.nsfw)),
        ],
      ],
    );
  }
}
