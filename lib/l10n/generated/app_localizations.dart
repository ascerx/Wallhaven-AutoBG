import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallhaven Client'**
  String get appTitle;

  /// No description provided for @tabAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get tabAuto;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @autoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto wallpaper'**
  String get autoSectionTitle;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get statusRunning;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get statusStopped;

  /// No description provided for @intervalSummary.
  ///
  /// In en, this message translates to:
  /// **'Changes every {minutes} min'**
  String intervalSummary(int minutes);

  /// No description provided for @nextChangeIn.
  ///
  /// In en, this message translates to:
  /// **'Next change in {time}'**
  String nextChangeIn(String time);

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @stopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopButton;

  /// No description provided for @changeNowButton.
  ///
  /// In en, this message translates to:
  /// **'Change now'**
  String get changeNowButton;

  /// No description provided for @currentWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Current wallpaper'**
  String get currentWallpaper;

  /// No description provided for @noWallpaperYet.
  ///
  /// In en, this message translates to:
  /// **'No wallpaper applied yet.'**
  String get noWallpaperYet;

  /// No description provided for @lastError.
  ///
  /// In en, this message translates to:
  /// **'Last error: {error}'**
  String lastError(String error);

  /// No description provided for @autoStartOnLaunch.
  ///
  /// In en, this message translates to:
  /// **'Start automatically when the app opens'**
  String get autoStartOnLaunch;

  /// No description provided for @searchSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved search'**
  String get searchSectionTitle;

  /// No description provided for @queryLabel.
  ///
  /// In en, this message translates to:
  /// **'Search query'**
  String get queryLabel;

  /// No description provided for @queryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. mountains, +nature -city, @username'**
  String get queryHint;

  /// No description provided for @categoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesLabel;

  /// No description provided for @catGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get catGeneral;

  /// No description provided for @catAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get catAnime;

  /// No description provided for @catPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get catPeople;

  /// No description provided for @purityLabel.
  ///
  /// In en, this message translates to:
  /// **'Content rating'**
  String get purityLabel;

  /// No description provided for @purSfw.
  ///
  /// In en, this message translates to:
  /// **'SFW'**
  String get purSfw;

  /// No description provided for @purSketchy.
  ///
  /// In en, this message translates to:
  /// **'Sketchy'**
  String get purSketchy;

  /// No description provided for @purNsfw.
  ///
  /// In en, this message translates to:
  /// **'NSFW'**
  String get purNsfw;

  /// No description provided for @nsfwNeedsKey.
  ///
  /// In en, this message translates to:
  /// **'NSFW requires an API key (add it in Settings).'**
  String get nsfwNeedsKey;

  /// No description provided for @minResLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum resolution'**
  String get minResLabel;

  /// No description provided for @noMinRes.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get noMinRes;

  /// No description provided for @ratiosLabel.
  ///
  /// In en, this message translates to:
  /// **'Aspect ratio'**
  String get ratiosLabel;

  /// No description provided for @sortingLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortingLabel;

  /// No description provided for @sortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get sortDateAdded;

  /// No description provided for @sortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get sortRelevance;

  /// No description provided for @sortRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get sortRandom;

  /// No description provided for @sortViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get sortViews;

  /// No description provided for @sortFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get sortFavorites;

  /// No description provided for @sortToplist.
  ///
  /// In en, this message translates to:
  /// **'Toplist'**
  String get sortToplist;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @orderDesc.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get orderDesc;

  /// No description provided for @orderAsc.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get orderAsc;

  /// No description provided for @topRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Toplist range'**
  String get topRangeLabel;

  /// No description provided for @range1d.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get range1d;

  /// No description provided for @range3d.
  ///
  /// In en, this message translates to:
  /// **'Last 3 days'**
  String get range3d;

  /// No description provided for @range1w.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get range1w;

  /// No description provided for @range1M.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get range1M;

  /// No description provided for @range3M.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get range3M;

  /// No description provided for @range6M.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get range6M;

  /// No description provided for @range1y.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get range1y;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Dominant color'**
  String get colorLabel;

  /// No description provided for @noColor.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get noColor;

  /// No description provided for @testSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Test this search'**
  String get testSearchButton;

  /// No description provided for @testingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get testingLabel;

  /// No description provided for @testResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'First results'**
  String get testResultsTitle;

  /// No description provided for @testNoResults.
  ///
  /// In en, this message translates to:
  /// **'No wallpapers found for this search.'**
  String get testNoResults;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @savedMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get savedMessage;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailed(String error);

  /// No description provided for @viewMoreButton.
  ///
  /// In en, this message translates to:
  /// **'See all results'**
  String get viewMoreButton;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get galleryTitle;

  /// No description provided for @noMoreResults.
  ///
  /// In en, this message translates to:
  /// **'No more results.'**
  String get noMoreResults;

  /// No description provided for @downloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadButton;

  /// No description provided for @downloadDone.
  ///
  /// In en, this message translates to:
  /// **'Saved: {path}'**
  String downloadDone(String path);

  /// No description provided for @autoCleanupLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-cleanup (downloads)'**
  String get autoCleanupLabel;

  /// No description provided for @autoCleanupKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep last {count}'**
  String autoCleanupKeep(int count);

  /// No description provided for @autoCleanupUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get autoCleanupUnlimited;

  /// No description provided for @selectionMode.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectionMode;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelSelection;

  /// No description provided for @downloadSelected.
  ///
  /// In en, this message translates to:
  /// **'Download {count}'**
  String downloadSelected(int count);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @batchProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading {done}/{total}…'**
  String batchProgress(int done, int total);

  /// No description provided for @batchDone.
  ///
  /// In en, this message translates to:
  /// **'{count} downloaded'**
  String batchDone(int count);

  /// No description provided for @startupLabel.
  ///
  /// In en, this message translates to:
  /// **'Run at system startup'**
  String get startupLabel;

  /// No description provided for @hotkeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Global hotkey Ctrl+Alt+W: change wallpaper'**
  String get hotkeyLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @sourceSearch.
  ///
  /// In en, this message translates to:
  /// **'Saved search'**
  String get sourceSearch;

  /// No description provided for @sourceCollection.
  ///
  /// In en, this message translates to:
  /// **'User collection'**
  String get sourceCollection;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallhaven username'**
  String get usernameLabel;

  /// No description provided for @loadCollections.
  ///
  /// In en, this message translates to:
  /// **'Load my collections'**
  String get loadCollections;

  /// No description provided for @collectionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionsLabel;

  /// No description provided for @collectionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No collections found.'**
  String get collectionsEmpty;

  /// No description provided for @collectionsNeedKey.
  ///
  /// In en, this message translates to:
  /// **'An API key is required to load collections.'**
  String get collectionsNeedKey;

  /// No description provided for @resolutionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Exact resolutions'**
  String get resolutionsLabel;

  /// No description provided for @allWideChip.
  ///
  /// In en, this message translates to:
  /// **'All wide'**
  String get allWideChip;

  /// No description provided for @allPortraitChip.
  ///
  /// In en, this message translates to:
  /// **'All portrait'**
  String get allPortraitChip;

  /// No description provided for @androidNote.
  ///
  /// In en, this message translates to:
  /// **'On Android the wallpaper is applied to the home screen.'**
  String get androidNote;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @trayShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get trayShow;

  /// No description provided for @trayExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get trayExit;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openInBrowser;

  /// No description provided for @uploadedBy.
  ///
  /// In en, this message translates to:
  /// **'Uploaded by {name}'**
  String uploadedBy(String name);

  /// No description provided for @totalDiskUsage.
  ///
  /// In en, this message translates to:
  /// **'{size} on disk'**
  String totalDiskUsage(String size);

  /// No description provided for @downloadsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} downloads'**
  String downloadsCount(int count);

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @deleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete file'**
  String get deleteFile;

  /// No description provided for @fileDeleted.
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get fileDeleted;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @historySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'History & downloads'**
  String get historySectionTitle;

  /// No description provided for @openFolderButton.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolderButton;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'Nothing downloaded yet.'**
  String get noHistory;

  /// No description provided for @reapplyButton.
  ///
  /// In en, this message translates to:
  /// **'Set as wallpaper'**
  String get reapplyButton;

  /// No description provided for @appliedAt.
  ///
  /// In en, this message translates to:
  /// **'Applied {date}'**
  String appliedAt(String date);

  /// No description provided for @settingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSectionTitle;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallhaven API key'**
  String get apiKeyLabel;

  /// No description provided for @apiKeyHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional. Unlocks NSFW content and your private collections. Generate one at wallhaven.cc → Settings → Account.'**
  String get apiKeyHelper;

  /// No description provided for @intervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Change interval (minutes)'**
  String get intervalLabel;

  /// No description provided for @intervalValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number greater than or equal to 1.'**
  String get intervalValidation;

  /// No description provided for @downloadFolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Download folder'**
  String get downloadFolderLabel;

  /// No description provided for @chooseFolderButton.
  ///
  /// In en, this message translates to:
  /// **'Choose…'**
  String get chooseFolderButton;

  /// No description provided for @fitLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper fit (Windows)'**
  String get fitLabel;

  /// No description provided for @fitFill.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get fitFill;

  /// No description provided for @fitStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get fitStretch;

  /// No description provided for @fitFit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get fitFit;

  /// No description provided for @fitCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get fitCenter;

  /// No description provided for @fitTile.
  ///
  /// In en, this message translates to:
  /// **'Tile'**
  String get fitTile;

  /// No description provided for @rateNote.
  ///
  /// In en, this message translates to:
  /// **'Wallhaven limits the API to 45 requests per minute.'**
  String get rateNote;

  /// No description provided for @wallpaperSet.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper set ({id})'**
  String wallpaperSet(String id);

  /// No description provided for @wallpaperSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not set the wallpaper: {error}'**
  String wallpaperSetFailed(String error);

  /// No description provided for @wallpaperUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Setting the wallpaper is not supported on this platform yet ({platform}).'**
  String wallpaperUnsupported(String platform);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
