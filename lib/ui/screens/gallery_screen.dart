import 'dart:io';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';

import '../../models/search_options.dart';
import '../../models/wallpaper.dart';
import '../../services/auto_changer.dart';
import '../../services/downloader.dart';
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

  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
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
      ),
      body: _items.isEmpty && _loading
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 16 / 10,
                      ),
                      itemCount: _items.length + (_hasMore || _loading ? 1 : 0),
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
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
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
          ],
        ),
      ),
    );
  }
}

class _GalleryDetail extends StatelessWidget {
  const _GalleryDetail({required this.wallpaper});

  final Wallpaper wallpaper;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final changer = context.read<AutoChanger>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${wallpaper.id} · ${wallpaper.resolution}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: Image.network(
                  wallpaper.thumbs.original,
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
                  FilledButton.icon(
                    onPressed: () async {
                      final ok = await changer.applyWallpaper(wallpaper);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? l.wallpaperSet(wallpaper.id)
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
                            final downloader = context.read<WallpaperDownloader>();
                            try {
                              final file = await downloader.downloadWallpaper(
                                wallpaper,
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
                                  content: Text(l.searchFailed(
                                    error.toString(),
                                  )),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.download_outlined),
                          label: Text(l.downloadButton),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${wallpaper.resolution} · ${wallpaper.purity} · ${wallpaper.category}',
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
