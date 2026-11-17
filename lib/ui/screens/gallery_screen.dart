import 'dart:io';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';

import '../../models/history_entry.dart';
import '../../models/search_options.dart';
import '../../models/wallpaper.dart';
import '../../services/auto_changer.dart';
import '../../services/downloader.dart';
import '../../services/history_repository.dart';
import '../../services/wallhaven_api.dart';
import '../../state/app_state.dart';

/// Paginated grid of every result for a search, with a detail view to apply
/// or download wallpapers on demand.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, required this.options});

  final SearchOptions options;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<Wallpaper> _items = [];
  final ScrollController _scroll = ScrollController();
  final Random _rng = Random();
  final Set<int> _selectedIndexes = {};

  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  bool _selecting = false;
  bool _batchDownloading = false;
  int _batchDone = 0;
  int _batchTotal = 0;
  String? _seed;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      if (_seed == null && widget.options.sorting == Sorting.random) {
        // A stable seed keeps pages consistent and avoids repeats.
        const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        _seed = List.generate(
          6,
          (_) => chars[_rng.nextInt(chars.length)],
        ).join();
      }
      _page++;
      final page = await context.read<WallhavenApi>().search(
            widget.options,
            page: _page,
            seed: _seed,
          );
      if (!mounted) return;
      setState(() {
        _items.addAll(page.wallpapers);
        if (page.wallpapers.length < 24) _hasMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _hasMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.searchFailed(
            error.toString(),
          )),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadSelected() async {
    if (_batchDownloading || _selectedIndexes.isEmpty) return;
    setState(() => _batchDownloading = true);
    final l = AppLocalizations.of(context)!;
    final downloader = context.read<WallpaperDownloader>();
    final state = context.read<AppState>();
    final history = context.read<HistoryRepository>();
    final changer = context.read<AutoChanger>();

    var ok = 0;
    final total = _selectedIndexes.length;
    var done = 0;
    if (mounted) {
      setState(() {
        _batchDone = 0;
        _batchTotal = total;
      });
    }
    for (final index in _selectedIndexes.toList()) {
      final wallpaper = _items[index];
      try {
        final file = await downloader.downloadWallpaper(
          wallpaper,
          Directory(state.downloadDir),
        );
        await history.add(HistoryEntry(
          id: wallpaper.id,
          fileUrl: wallpaper.fileUrl,
          thumbUrl: wallpaper.thumbs.large,
          resolution: wallpaper.resolution,
          filePath: file.path,
          appliedAt: DateTime.now(),
        ));
        ok++;
      } on Exception {
        // Skip failed downloads and keep going.
      }
      done++;
      if (mounted) setState(() => _batchDone = done);
    }
    await changer.pruneDownloads();

    if (!mounted) return;
    setState(() {
      _batchDownloading = false;
      _selecting = false;
      _selectedIndexes.clear();
      _batchDone = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.batchDone(ok))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.options.query.isEmpty
              ? l.galleryTitle
              : '${l.galleryTitle} · ${widget.options.query}',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: _selecting ? l.cancelSelection : l.selectionMode,
            icon: Icon(_selecting ? Icons.close : Icons.checklist_rtl),
            onPressed: () => setState(() {
              _selecting = !_selecting;
              _selectedIndexes.clear();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty && _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(child: Text(l.testNoResults))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final cross =
                              (constraints.maxWidth / 250).floor().clamp(2, 6);
                          return GridView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cross,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 16 / 10,
                            ),
                            itemCount:
                                _items.length + (_hasMore || _loading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _items.length) {
                                return _hasMore
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Center(child: Text(l.noMoreResults));
                              }
                              return _GalleryTile(
                                wallpaper: _items[index],
                                selecting: _selecting,
                                selected: _selectedIndexes.contains(index),
                                onToggle: _selecting
                                    ? () => setState(() {
                                          _selectedIndexes.contains(index)
                                              ? _selectedIndexes.remove(index)
                                              : _selectedIndexes.add(index);
                                        })
                                    : null,
                              );
                            },
                          );
                        },
                      ),
          ),
          if (_selecting)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _batchDownloading
                            ? l.batchProgress(_batchDone, _batchTotal)
                            : l.selectedCount(_selectedIndexes.length),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: (_batchDownloading ||
                              _selectedIndexes.isEmpty)
                          ? null
                          : () => _downloadSelected(),
                      icon: _batchDownloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(_batchDownloading
                          ? '...'
                          : l.downloadSelected(_selectedIndexes.length)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.wallpaper,
    this.selecting = false,
    this.selected = false,
    this.onToggle,
  });

  final Wallpaper wallpaper;
  final bool selecting;
  final bool selected;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: selecting && onToggle != null
          ? onToggle
          : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => _GalleryDetail(wallpaper: wallpaper),
              )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              wallpaper.thumbs.large,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                child: Text(
                  '${wallpaper.id} · ${wallpaper.resolution}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (selecting)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black45,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    selected ? Icons.check : Icons.circle_outlined,
                    size: 18,
                    color: selected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GalleryDetail extends StatefulWidget {
  const _GalleryDetail({required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  State<_GalleryDetail> createState() => _GalleryDetailState();
}

class _GalleryDetailState extends State<_GalleryDetail> {
  late final Future<Wallpaper> _info;

  @override
  void initState() {
    super.initState();
    _info = context.read<WallhavenApi>().wallpaperInfo(widget.wallpaper.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final changer = context.read<AutoChanger>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${widget.wallpaper.id} · ${widget.wallpaper.resolution}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: Image.network(
                  widget.wallpaper.thumbs.original,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white38,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tags, uploader and page link (full info endpoint).
                  FutureBuilder<Wallpaper>(
                    future: _info,
                    builder: (context, snapshot) {
                      final info = snapshot.data;
                      if (info == null) return const SizedBox.shrink();
                      final tags = (info.uploaderUsername == null &&
                              info.tagNames.isEmpty)
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (info.tagNames.isNotEmpty) ...[
                                  Text(
                                    l.tagsLabel,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      for (final tag in info.tagNames)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                if (info.uploaderUsername != null)
                                  Text(
                                    l.uploadedBy(info.uploaderUsername!),
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                              ],
                            );
                      return tags;
                    },
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      final ok = await changer.applyWallpaper(widget.wallpaper);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? l.wallpaperSet(widget.wallpaper.id)
                                : l.wallpaperSetFailed(
                                    changer.lastError ?? ''),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.wallpaper),
                    label: Text(l.reapplyButton),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          onPressed: () async {
                            final state = context.read<AppState>();
                            final downloader =
                                context.read<WallpaperDownloader>();
                            try {
                              final file = await downloader.downloadWallpaper(
                                widget.wallpaper,
                                Directory(state.downloadDir),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l.downloadDone(file.path)),
                                ),
                              );
                            } catch (error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(l.searchFailed(error.toString())),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: Text(l.downloadButton),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          final url = Uri.parse(widget.wallpaper.pageUrl);
                          if (url.toString().isNotEmpty) {
                            launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: const Icon(Icons.open_in_new, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.wallpaper.resolution} · ${widget.wallpaper.purity} · ${widget.wallpaper.category}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

