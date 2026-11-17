import 'package:material_ui/material_ui.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/history_entry.dart';
import '../../services/auto_changer.dart';
import '../../services/history_repository.dart';
import '../../state/app_state.dart';
import '../../utils/open_folder.dart';
import '../widgets/common.dart';

/// Previously downloaded wallpapers; tapping the action re-applies one.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _reapply(BuildContext context, HistoryEntry entry) async {
    final changer = context.read<AutoChanger>();
    final ok = await changer.applyExisting(entry);
    if (!context.mounted) return;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l.wallpaperSet(entry.id) : l.wallpaperSetFailed(changer.lastError ?? ''),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final history = context.watch<HistoryRepository>();
    final state = context.watch<AppState>();

    return Column(
      children: [
        SectionCard(
          title: l.historySectionTitle,
          trailing: OutlinedButton.icon(
            onPressed: () async {
              final ok = await openFolderInFileManager(state.downloadDir);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.downloadDir)),
                );
              }
            },
            icon: const Icon(Icons.folder_open),
            label: Text(l.openFolderButton),
          ),
          child: Text(
            state.downloadDir,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: history.entries.isEmpty
              ? Center(child: Text(l.noHistory))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: history.entries.length,
                  itemBuilder: (context, index) {
                    final entry = history.entries[index];
                    final date = DateFormat('yyyy-MM-dd HH:mm')
                        .format(entry.appliedAt.toLocal());
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            entry.thumbUrl,
                            width: 72,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => SizedBox(
                              width: 72,
                              height: 44,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.image_not_supported_outlined,
                                      size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        title: Text('${entry.id} · ${entry.resolution}'),
                        subtitle: Text(l.appliedAt(date)),
                        trailing: IconButton(
                          tooltip: l.reapplyButton,
                          icon: const Icon(Icons.wallpaper),
                          onPressed: () => _reapply(context, entry),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
