// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Wallhaven Client';

  @override
  String get tabAuto => 'Auto';

  @override
  String get tabSearch => 'Suche';

  @override
  String get tabHistory => 'Verlauf';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get autoSectionTitle => 'Automatisches Hintergrundbild';

  @override
  String get statusRunning => 'Läuft';

  @override
  String get statusStopped => 'Gestoppt';

  @override
  String intervalSummary(int minutes) {
    return 'Wechselt alle $minutes Min.';
  }

  @override
  String nextChangeIn(String time) {
    return 'Nächster Wechsel in $time';
  }

  @override
  String get startButton => 'Starten';

  @override
  String get stopButton => 'Stoppen';

  @override
  String get changeNowButton => 'Jetzt wechseln';

  @override
  String get currentWallpaper => 'Aktuelles Hintergrundbild';

  @override
  String get noWallpaperYet => 'Noch kein Hintergrundbild angewendet.';

  @override
  String lastError(String error) {
    return 'Letzter Fehler: $error';
  }

  @override
  String get autoStartOnLaunch => 'Automatisch beim Öffnen der App starten';

  @override
  String get searchSectionTitle => 'Gespeicherte Suche';

  @override
  String get queryLabel => 'Suchanfrage';

  @override
  String get queryHint => 'z. B. mountains, +nature -city, @benutzer';

  @override
  String get categoriesLabel => 'Kategorien';

  @override
  String get catGeneral => 'Allgemein';

  @override
  String get catAnime => 'Anime';

  @override
  String get catPeople => 'Menschen';

  @override
  String get purityLabel => 'Inhaltsbewertung';

  @override
  String get purSfw => 'SFW';

  @override
  String get purSketchy => 'Sketchy';

  @override
  String get purNsfw => 'NSFW';

  @override
  String get nsfwNeedsKey =>
      'NSFW erfordert einen API-Schlüssel (in Einstellungen hinzufügen).';

  @override
  String get minResLabel => 'Mindestauflösung';

  @override
  String get noMinRes => 'Beliebig';

  @override
  String get ratiosLabel => 'Seitenverhältnis';

  @override
  String get sortingLabel => 'Sortieren nach';

  @override
  String get sortDateAdded => 'Datum';

  @override
  String get sortRelevance => 'Relevanz';

  @override
  String get sortRandom => 'Zufällig';

  @override
  String get sortViews => 'Aufrufe';

  @override
  String get sortFavorites => 'Favoriten';

  @override
  String get sortToplist => 'Toplist';

  @override
  String get orderLabel => 'Reihenfolge';

  @override
  String get orderDesc => 'Absteigend';

  @override
  String get orderAsc => 'Aufsteigend';

  @override
  String get topRangeLabel => 'Toplist-Zeitraum';

  @override
  String get range1d => 'Letzter Tag';

  @override
  String get range3d => 'Letzte 3 Tage';

  @override
  String get range1w => 'Letzte Woche';

  @override
  String get range1M => 'Letzter Monat';

  @override
  String get range3M => 'Letzte 3 Monate';

  @override
  String get range6M => 'Letzte 6 Monate';

  @override
  String get range1y => 'Letztes Jahr';

  @override
  String get colorLabel => 'Dominante Farbe';

  @override
  String get noColor => 'Beliebig';

  @override
  String get testSearchButton => 'Diese Suche testen';

  @override
  String get testingLabel => 'Lädt…';

  @override
  String get testResultsTitle => 'Erste Ergebnisse';

  @override
  String get testNoResults =>
      'Keine Hintergrundbilder für diese Suche gefunden.';

  @override
  String get saveButton => 'Speichern';

  @override
  String get savedMessage => 'Einstellungen gespeichert.';

  @override
  String searchFailed(String error) {
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String get viewMoreButton => 'Alle Ergebnisse anzeigen';

  @override
  String get galleryTitle => 'Ergebnisse';

  @override
  String get noMoreResults => 'Keine weiteren Ergebnisse.';

  @override
  String get downloadButton => 'Herunterladen';

  @override
  String downloadDone(String path) {
    return 'Gespeichert: $path';
  }

  @override
  String get autoCleanupLabel => 'Auto-Bereinigung (Downloads)';

  @override
  String autoCleanupKeep(int count) {
    return 'Letzte $count behalten';
  }

  @override
  String get autoCleanupUnlimited => 'Unbegrenzt';

  @override
  String get selectionMode => 'Auswählen';

  @override
  String get cancelSelection => 'Abbrechen';

  @override
  String downloadSelected(int count) {
    return '$count herunterladen';
  }

  @override
  String selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String batchProgress(int done, int total) {
    return 'Lade $done/$total herunter…';
  }

  @override
  String batchDone(int count) {
    return '$count heruntergeladen';
  }

  @override
  String get startupLabel => 'Beim Systemstart ausführen';

  @override
  String get hotkeyLabel =>
      'Globale Tastenkombination Strg+Alt+W: Hintergrund wechseln';

  @override
  String get sourceLabel => 'Quelle';

  @override
  String get sourceSearch => 'Gespeicherte Suche';

  @override
  String get sourceCollection => 'Benutzersammlung';

  @override
  String get usernameLabel => 'Wallhaven-Benutzername';

  @override
  String get loadCollections => 'Meine Sammlungen laden';

  @override
  String get collectionsLabel => 'Sammlung';

  @override
  String get collectionsEmpty => 'Keine Sammlungen gefunden.';

  @override
  String get collectionsNeedKey =>
      'Zum Laden von Sammlungen ist ein API-Schlüssel erforderlich.';

  @override
  String get resolutionsLabel => 'Exakte Auflösungen';

  @override
  String get allWideChip => 'Alle breiten';

  @override
  String get allPortraitChip => 'Alle hochformatigen';

  @override
  String get androidNote =>
      'Auf Android läuft die Rotation als Vordergrunddienst: Sie funktioniert auch, wenn die App geschlossen ist.';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get trayShow => 'Anzeigen';

  @override
  String get trayExit => 'Beenden';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get openInBrowser => 'Im Browser öffnen';

  @override
  String uploadedBy(String name) {
    return 'Hochgeladen von $name';
  }

  @override
  String totalDiskUsage(String size) {
    return '$size auf der Festplatte';
  }

  @override
  String downloadsCount(int count) {
    return '$count Downloads';
  }

  @override
  String get clearHistory => 'Verlauf löschen';

  @override
  String get deleteFile => 'Datei löschen';

  @override
  String get fileDeleted => 'Datei gelöscht';

  @override
  String get historyCleared => 'Verlauf gelöscht';

  @override
  String get historySectionTitle => 'Verlauf & Downloads';

  @override
  String get openFolderButton => 'Ordner öffnen';

  @override
  String get noHistory => 'Noch nichts heruntergeladen.';

  @override
  String get reapplyButton => 'Als Hintergrundbild festlegen';

  @override
  String appliedAt(String date) {
    return 'Angewendet am $date';
  }

  @override
  String get settingsSectionTitle => 'Einstellungen';

  @override
  String get apiKeyLabel => 'Wallhaven-API-Schlüssel';

  @override
  String get apiKeyHelper =>
      'Optional. Schaltet NSFW-Inhalte und private Sammlungen frei. Erstelle einen auf wallhaven.cc → Einstellungen → Konto.';

  @override
  String get intervalLabel => 'Wechselintervall (Minuten)';

  @override
  String get intervalValidation => 'Ganze Zahl größer oder gleich 1 eingeben.';

  @override
  String get downloadFolderLabel => 'Download-Ordner';

  @override
  String get chooseFolderButton => 'Auswählen…';

  @override
  String get fitLabel => 'Hintergrundanpassung (Windows)';

  @override
  String get fitFill => 'Füllen';

  @override
  String get fitStretch => 'Strecken';

  @override
  String get fitFit => 'Einpassen';

  @override
  String get fitCenter => 'Zentrieren';

  @override
  String get fitTile => 'Kacheln';

  @override
  String get rateNote =>
      'Wallhaven begrenzt die API auf 45 Anfragen pro Minute.';

  @override
  String wallpaperSet(String id) {
    return 'Hintergrundbild gesetzt ($id)';
  }

  @override
  String wallpaperSetFailed(String error) {
    return 'Hintergrundbild konnte nicht gesetzt werden: $error';
  }

  @override
  String wallpaperUnsupported(String platform) {
    return 'Das Festlegen des Hintergrundbilds wird auf dieser Plattform noch nicht unterstützt ($platform).';
  }
}
