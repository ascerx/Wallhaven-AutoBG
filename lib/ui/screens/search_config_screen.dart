import 'package:material_ui/material_ui.dart';
import 'package:wallhaven_client/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/collection.dart';
import '../../models/search_options.dart';
import '../../models/wallpaper.dart';
import '../../services/wallhaven_api.dart';
import '../../state/app_state.dart';
import '../widgets/common.dart';
import 'gallery_screen.dart';

/// Configure the saved search that drives the auto wallpaper rotation.
class SearchConfigScreen extends StatefulWidget {
  const SearchConfigScreen({super.key});

  @override
  State<SearchConfigScreen> createState() => _SearchConfigScreenState();
}

class _SearchConfigScreenState extends State<SearchConfigScreen> {
  late final TextEditingController _query;
  late Set<WallpaperCategory> _categories;
  late Set<Purity> _purity;
  // '' means "any".
  String _atleast = '';
  List<String> _ratios = const [];
  List<String> _resolutions = const [];
  late Sorting _sorting;
  late SortOrder _order;
  String? _topRange;
  String _color = '';

  // Collection-as-source state.
  bool _useCollection = false;
  late final TextEditingController _collectionUser;
  String? _collectionId;
  String? _collectionLabel;
  List<Collection>? _collections;
  bool _loadingCollections = false;

  bool _testing = false;
  List<Wallpaper>? _results;
  String? _testError;

  static const List<String> _minResOptions = [
    '1280x720',
    '1920x1080',
    '2560x1440',
    '3840x2160',
  ];
  static const List<String> _topRanges = ['1d', '3d', '1w', '1M', '3M', '6M', '1y'];

  @override
  void initState() {
    super.initState();
    final options = context.read<AppState>().options;
    _query = TextEditingController(text: options.query);
    _categories = {...options.categories};
    _purity = {...options.purity};
    _atleast = options.atleast ?? '';
    _ratios = List.of(options.ratios);
    _resolutions = List.of(options.resolutions);
    _useCollection = options.collectionId != null;
    _collectionId = options.collectionId;
    _collectionLabel = options.collectionLabel;
    _collectionUser = TextEditingController(
      text: options.collectionUser ??
          context.read<AppState>().wallhavenUser,
    );
    _sorting = options.sorting;
    _order = options.order;
    _topRange = options.topRange ?? '1M';
    _color = options.color ?? '';
  }

  @override
  void dispose() {
    _query.dispose();
    _collectionUser.dispose();
    super.dispose();
  }

  void _toggleRatioSet(List<String> set) {
    setState(() {
      final all = set.every(_ratios.contains);
      if (all) {
        _ratios = _ratios.where((r) => !set.contains(r)).toList();
      } else {
        _ratios = {..._ratios, ...set}.toList();
      }
    });
  }

  Future<void> _loadCollections() async {
    setState(() => _loadingCollections = true);
    try {
      final list = await context.read<WallhavenApi>().collections();
      if (!mounted) return;
      setState(() {
        _collections = list;
        _loadingCollections = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _collections = [];
        _loadingCollections = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.searchFailed(
            error.toString(),
          )),
        ),
      );
    }
  }

  SearchOptions _buildOptions() => SearchOptions(
        query: _query.text,
        categories: _categories.isEmpty
            ? const {
                WallpaperCategory.general,
                WallpaperCategory.anime,
                WallpaperCategory.people,
              }
            : _categories,
        purity: _purity.isEmpty ? const {Purity.sfw} : _purity,
        atleast: _atleast.isEmpty ? null : _atleast,
        ratios: _ratios,
        resolutions: _resolutions,
        collectionUser: _useCollection && _collectionUser.text.isNotEmpty
            ? _collectionUser.text.trim()
            : null,
        collectionId: _useCollection ? _collectionId : null,
        collectionLabel: _useCollection ? _collectionLabel : null,
        sorting: _sorting,
        order: _order,
        topRange: _topRange,
        color: _color.isEmpty ? null : _color,
      );

  String _sortingLabel(Sorting sorting, AppLocalizations l) => switch (sorting) {
        Sorting.dateAdded => l.sortDateAdded,
        Sorting.relevance => l.sortRelevance,
        Sorting.random => l.sortRandom,
        Sorting.views => l.sortViews,
        Sorting.favorites => l.sortFavorites,
        Sorting.toplist => l.sortToplist,
      };

  String _topRangeLabel(String range, AppLocalizations l) => switch (range) {
        '1d' => l.range1d,
        '3d' => l.range3d,
        '1w' => l.range1w,
        '1M' => l.range1M,
        '3M' => l.range3M,
        '6M' => l.range6M,
        '1y' => l.range1y,
        _ => range,
      };

  Future<void> _save() async {
    final state = context.read<AppState>();
    await state.updateOptions(_buildOptions());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(AppLocalizations.of(context)!.savedMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _testSearch() async {
    setState(() {
      _testing = true;
      _testError = null;
      _results = null;
    });
    try {
      final page = await context.read<WallhavenApi>().search(_buildOptions());
      if (!mounted) return;
      setState(() => _results = page.wallpapers);
    } catch (error) {
      if (!mounted) return;
      setState(() => _testError = error.toString());
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hasApiKey = context.watch<AppState>().hasApiKey;

    return ListView(
      children: [
        SectionCard(
          title: l.searchSectionTitle,
          trailing: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(l.saveButton),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _query,
                decoration: InputDecoration(
                  labelText: l.queryLabel,
                  hintText: l.queryHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              FieldLabel(l.categoriesLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final category in WallpaperCategory.values)
                    FilterChip(
                      label: Text(
                        switch (category) {
                          WallpaperCategory.general => l.catGeneral,
                          WallpaperCategory.anime => l.catAnime,
                          WallpaperCategory.people => l.catPeople,
                        },
                      ),
                      selected: _categories.contains(category),
                      onSelected: (selected) => setState(() => selected
                          ? _categories.add(category)
                          : _categories.remove(category)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FieldLabel(l.purityLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final purity in Purity.values)
                    _purityChip(purity, l, hasApiKey),
                ],
              ),
              if (!hasApiKey && _purity.contains(Purity.nsfw)) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(l.nsfwNeedsKey)),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              FieldLabel(l.ratiosLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilterChip(
                    label: Text(l.allWideChip),
                    selected: SearchOptions.wideRatios
                        .every(_ratios.contains),
                    onSelected: (_) =>
                        _toggleRatioSet(SearchOptions.wideRatios),
                  ),
                  FilterChip(
                    label: Text(l.allPortraitChip),
                    selected: SearchOptions.portraitRatios
                        .every(_ratios.contains),
                    onSelected: (_) =>
                        _toggleRatioSet(SearchOptions.portraitRatios),
                  ),
                  for (final ratio in SearchOptions.availableRatios)
                    FilterChip(
                      label: Text(ratio),
                      selected: _ratios.contains(ratio),
                      onSelected: (selected) => setState(() => selected
                          ? _ratios = [..._ratios, ratio]
                          : _ratios = _ratios
                              .where((r) => r != ratio)
                              .toList()),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FieldLabel(l.resolutionsLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final resolution
                      in SearchOptions.availableResolutions)
                    FilterChip(
                      label: Text(resolution),
                      selected: _resolutions.contains(resolution),
                      onSelected: (selected) => setState(() => selected
                          ? _resolutions = [..._resolutions, resolution]
                          : _resolutions = _resolutions
                              .where((r) => r != resolution)
                              .toList()),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _atleast,
                decoration: InputDecoration(
                  labelText: l.minResLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text(l.noMinRes)),
                  for (final res in _minResOptions)
                    DropdownMenuItem(value: res, child: Text(res)),
                ],
                onChanged: (value) => setState(() => _atleast = value ?? ''),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Sorting>(
                initialValue: _sorting,
                decoration: InputDecoration(
                  labelText: l.sortingLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final sorting in Sorting.values)
                    DropdownMenuItem(
                      value: sorting,
                      child: Text(_sortingLabel(sorting, l)),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _sorting = value ?? Sorting.random),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SortOrder>(
                initialValue: _order,
                decoration: InputDecoration(
                  labelText: l.orderLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: SortOrder.desc,
                    child: Text(l.orderDesc),
                  ),
                  DropdownMenuItem(
                    value: SortOrder.asc,
                    child: Text(l.orderAsc),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _order = value ?? SortOrder.desc),
              ),
              if (_sorting == Sorting.toplist) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _topRange,
                  decoration: InputDecoration(
                    labelText: l.topRangeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final range in _topRanges)
                      DropdownMenuItem(
                        value: range,
                        child: Text(_topRangeLabel(range, l)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _topRange = value),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _color,
                decoration: InputDecoration(
                  labelText: l.colorLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text(l.noColor)),
                  for (final color in SearchOptions.availableColors)
                    DropdownMenuItem(
                      value: color,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(int.parse('0xFF$color')),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('#$color'),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _color = value ?? ''),
              ),
              const SizedBox(height: 16),
              FieldLabel(l.sourceLabel),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _useCollection ? 'collection' : 'search',
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'search', child: Text(l.sourceSearch)),
                  DropdownMenuItem(
                      value: 'collection', child: Text(l.sourceCollection)),
                ],
                onChanged: (value) =>
                    setState(() => _useCollection = value == 'collection'),
              ),
              if (_useCollection) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _collectionUser,
                  decoration: InputDecoration(
                    labelText: l.usernameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                if (!context.watch<AppState>().hasApiKey)
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(l.collectionsNeedKey)),
                    ],
                  )
                else ...[
                  OutlinedButton.icon(
                    onPressed: _loadingCollections ? null : _loadCollections,
                    icon: _loadingCollections
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(l.loadCollections),
                  ),
                  if (_collections != null) ...[
                    const SizedBox(height: 8),
                    if (_collections!.isEmpty)
                      Text(l.collectionsEmpty)
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _collectionId,
                        decoration: InputDecoration(
                          labelText: l.collectionsLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final collection in _collections!)
                            DropdownMenuItem(
                              value: '${collection.id}',
                              child: Text(
                                  '${collection.label} (${collection.count})'),
                            ),
                        ],
                        onChanged: (value) => setState(() {
                          _collectionId = value;
                          _collectionLabel = _collections!
                              .where((c) => '${c.id}' == value)
                              .map((c) => c.label)
                              .firstOrNull;
                        }),
                      ),
                  ],
                ],
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => GalleryScreen(options: _buildOptions()),
                  )),
                  icon: const Icon(Icons.grid_view_outlined),
                  label: Text(l.viewMoreButton),
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          title: l.testResultsTitle,
          trailing: OutlinedButton.icon(
            onPressed: _testing ? null : _testSearch,
            icon: _testing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_testing ? l.testingLabel : l.testSearchButton),
          ),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: _buildResults(l),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _purityChip(Purity purity, AppLocalizations l, bool hasApiKey) {
    final enabled = hasApiKey || purity != Purity.nsfw;
    final chip = FilterChip(
      label: Text(switch (purity) {
        Purity.sfw => l.purSfw,
        Purity.sketchy => l.purSketchy,
        Purity.nsfw => l.purNsfw,
      }),
      selected: _purity.contains(purity),
      onSelected: enabled
          ? (selected) =>
              setState(() => selected ? _purity.add(purity) : _purity.remove(purity))
          : null,
    );
    if (!enabled) {
      return Tooltip(message: l.nsfwNeedsKey, child: chip);
    }
    return chip;
  }

  Widget _buildResults(AppLocalizations l) {
    if (_testing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_testError != null) {
      return Center(child: Text(l.searchFailed(_testError!)));
    }
    final results = _results;
    if (results == null || results.isEmpty) {
      return Center(child: Text(l.testNoResults));
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final wallpaper = results[index];
        return SizedBox(
          width: 210,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    wallpaper.thumbs.large,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${wallpaper.id} · ${wallpaper.resolution}',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
