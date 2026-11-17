// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wallhaven Client';

  @override
  String get tabAuto => 'Auto';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabHistory => 'History';

  @override
  String get tabSettings => 'Settings';

  @override
  String get autoSectionTitle => 'Auto wallpaper';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusStopped => 'Stopped';

  @override
  String intervalSummary(int minutes) {
    return 'Changes every $minutes min';
  }

  @override
  String nextChangeIn(String time) {
    return 'Next change in $time';
  }

  @override
  String get startButton => 'Start';

  @override
  String get stopButton => 'Stop';

  @override
  String get changeNowButton => 'Change now';

  @override
  String get currentWallpaper => 'Current wallpaper';

  @override
  String get noWallpaperYet => 'No wallpaper applied yet.';

  @override
  String lastError(String error) {
    return 'Last error: $error';
  }

  @override
  String get autoStartOnLaunch => 'Start automatically when the app opens';

  @override
  String get searchSectionTitle => 'Saved search';

  @override
  String get queryLabel => 'Search query';

  @override
  String get queryHint => 'e.g. mountains, +nature -city, @username';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get catGeneral => 'General';

  @override
  String get catAnime => 'Anime';

  @override
  String get catPeople => 'People';

  @override
  String get purityLabel => 'Content rating';

  @override
  String get purSfw => 'SFW';

  @override
  String get purSketchy => 'Sketchy';

  @override
  String get purNsfw => 'NSFW';

  @override
  String get nsfwNeedsKey => 'NSFW requires an API key (add it in Settings).';

  @override
  String get minResLabel => 'Minimum resolution';

  @override
  String get noMinRes => 'Any';

  @override
  String get ratiosLabel => 'Aspect ratio';

  @override
  String get sortingLabel => 'Sort by';

  @override
  String get sortDateAdded => 'Date added';

  @override
  String get sortRelevance => 'Relevance';

  @override
  String get sortRandom => 'Random';

  @override
  String get sortViews => 'Views';

  @override
  String get sortFavorites => 'Favorites';

  @override
  String get sortToplist => 'Toplist';

  @override
  String get orderLabel => 'Order';

  @override
  String get orderDesc => 'Descending';

  @override
  String get orderAsc => 'Ascending';

  @override
  String get topRangeLabel => 'Toplist range';

  @override
  String get range1d => 'Last day';

  @override
  String get range3d => 'Last 3 days';

  @override
  String get range1w => 'Last week';

  @override
  String get range1M => 'Last month';

  @override
  String get range3M => 'Last 3 months';

  @override
  String get range6M => 'Last 6 months';

  @override
  String get range1y => 'Last year';

  @override
  String get colorLabel => 'Dominant color';

  @override
  String get noColor => 'Any';

  @override
  String get testSearchButton => 'Test this search';

  @override
  String get testingLabel => 'Loading…';

  @override
  String get testResultsTitle => 'First results';

  @override
  String get testNoResults => 'No wallpapers found for this search.';

  @override
  String get saveButton => 'Save';

  @override
  String get savedMessage => 'Settings saved.';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get viewMoreButton => 'See all results';

  @override
  String get galleryTitle => 'Results';

  @override
  String get noMoreResults => 'No more results.';

  @override
  String get downloadButton => 'Download';

  @override
  String downloadDone(String path) {
    return 'Saved: $path';
  }

  @override
  String get autoCleanupLabel => 'Auto-cleanup (downloads)';

  @override
  String autoCleanupKeep(int count) {
    return 'Keep last $count';
  }

  @override
  String get autoCleanupUnlimited => 'Unlimited';

  @override
  String get selectionMode => 'Select';

  @override
  String get cancelSelection => 'Cancel';

  @override
  String downloadSelected(int count) {
    return 'Download $count';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String batchProgress(int done, int total) {
    return 'Downloading $done/$total…';
  }

  @override
  String batchDone(int count) {
    return '$count downloaded';
  }

  @override
  String get startupLabel => 'Run at system startup';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get trayShow => 'Show';

  @override
  String get trayExit => 'Exit';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String uploadedBy(String name) {
    return 'Uploaded by $name';
  }

  @override
  String totalDiskUsage(String size) {
    return '$size on disk';
  }

  @override
  String downloadsCount(int count) {
    return '$count downloads';
  }

  @override
  String get clearHistory => 'Clear history';

  @override
  String get deleteFile => 'Delete file';

  @override
  String get fileDeleted => 'File deleted';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get historySectionTitle => 'History & downloads';

  @override
  String get openFolderButton => 'Open folder';

  @override
  String get noHistory => 'Nothing downloaded yet.';

  @override
  String get reapplyButton => 'Set as wallpaper';

  @override
  String appliedAt(String date) {
    return 'Applied $date';
  }

  @override
  String get settingsSectionTitle => 'Settings';

  @override
  String get apiKeyLabel => 'Wallhaven API key';

  @override
  String get apiKeyHelper =>
      'Optional. Unlocks NSFW content and your private collections. Generate one at wallhaven.cc → Settings → Account.';

  @override
  String get intervalLabel => 'Change interval (minutes)';

  @override
  String get intervalValidation =>
      'Enter a whole number greater than or equal to 1.';

  @override
  String get downloadFolderLabel => 'Download folder';

  @override
  String get chooseFolderButton => 'Choose…';

  @override
  String get fitLabel => 'Wallpaper fit (Windows)';

  @override
  String get fitFill => 'Fill';

  @override
  String get fitStretch => 'Stretch';

  @override
  String get fitFit => 'Fit';

  @override
  String get fitCenter => 'Center';

  @override
  String get fitTile => 'Tile';

  @override
  String get rateNote => 'Wallhaven limits the API to 45 requests per minute.';

  @override
  String wallpaperSet(String id) {
    return 'Wallpaper set ($id)';
  }

  @override
  String wallpaperSetFailed(String error) {
    return 'Could not set the wallpaper: $error';
  }

  @override
  String wallpaperUnsupported(String platform) {
    return 'Setting the wallpaper is not supported on this platform yet ($platform).';
  }
}
