import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../services/startup.dart';
import '../../services/wallpaper/wallpaper_service.dart';
import '../../state/app_state.dart';
import '../widgets/common.dart';

/// API key, download folder, rotation interval and wallpaper fit.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiKey;
  late final TextEditingController _interval;
  late final TextEditingController _folder;
  WallpaperFit _fit = WallpaperFit.fill;
  int _maxDownloads = 50;
  String _localeCode = 'system';
  bool _runAtStartup = false;

  bool _obscureKey = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _apiKey = TextEditingController(text: state.apiKey);
    _interval =
        TextEditingController(text: state.intervalMinutes.toString());
    _folder = TextEditingController(text: state.downloadDir);
    _fit = state.fit;
    _maxDownloads = state.maxDownloads ?? -1;
    _localeCode = state.localeCode;
    _loadStartupState();
  }

  Future<void> _loadStartupState() async {
    final enabled = await StartupService().isEnabled();
    if (!mounted) return;
    setState(() => _runAtStartup = enabled);
  }

  Future<void> _toggleStartup(bool value) async {
    await StartupService().setEnabled(value);
    if (!mounted) return;
    setState(() => _runAtStartup = value);
  }

  @override
  void dispose() {
    _apiKey.dispose();
    _interval.dispose();
    _folder.dispose();
    super.dispose();
  }

  Future<void> _chooseFolder() async {
    final current = context.read<AppState>().downloadDir;
    final path = await getDirectoryPath(initialDirectory: current);
    if (path != null && mounted) {
      await context.read<AppState>().setDownloadDir(path);
      setState(() => _folder.text = path);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final state = context.read<AppState>();
    await state.setApiKey(_apiKey.text);
    await state.setIntervalMinutes(int.parse(_interval.text.trim()));
    await state.setFit(_fit);
    await state.setMaxDownloads(_maxDownloads == -1 ? null : _maxDownloads);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.savedMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    String fitLabel(WallpaperFit fit) => switch (fit) {
          WallpaperFit.fill => l.fitFill,
          WallpaperFit.stretch => l.fitStretch,
          WallpaperFit.fit => l.fitFit,
          WallpaperFit.center => l.fitCenter,
          WallpaperFit.tile => l.fitTile,
        };

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          SectionCard(
            title: l.settingsSectionTitle,
            trailing: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(l.saveButton),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _apiKey,
                  obscureText: _obscureKey,
                  decoration: InputDecoration(
                    labelText: l.apiKeyLabel,
                    helperText: l.apiKeyHelper,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _interval,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.intervalLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed < 1) {
                      return l.intervalValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _folder,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l.downloadFolderLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: l.chooseFolderButton,
                      icon: const Icon(Icons.folder_open),
                      onPressed: _chooseFolder,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<WallpaperFit>(
                  initialValue: _fit,
                  decoration: InputDecoration(
                    labelText: l.fitLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final fit in WallpaperFit.values)
                      DropdownMenuItem(value: fit, child: Text(fitLabel(fit))),
                  ],
                  onChanged: (value) =>
                      setState(() => _fit = value ?? WallpaperFit.fill),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _maxDownloads,
                  decoration: InputDecoration(
                    labelText: l.autoCleanupLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final count in const [25, 50, 100, 200, -1])
                      DropdownMenuItem(
                        value: count,
                        child: Text(
                          count == -1
                              ? l.autoCleanupUnlimited
                              : l.autoCleanupKeep(count),
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _maxDownloads = value ?? 50),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _localeCode,
                  decoration: InputDecoration(
                    labelText: l.languageLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(l.languageSystem),
                    ),
                    const DropdownMenuItem(
                      value: 'es',
                      child: Text('Español'),
                    ),
                    const DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                  ],
                  onChanged: (value) async {
                    setState(() => _localeCode = value ?? 'system');
                    await context
                        .read<AppState>()
                        .setLocaleCode(_localeCode);
                  },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _runAtStartup,
                  onChanged: (value) => _toggleStartup(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(l.startupLabel),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(l.rateNote)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
