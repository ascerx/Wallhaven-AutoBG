// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Client Wallhaven';

  @override
  String get tabAuto => 'Auto';

  @override
  String get tabSearch => 'Recherche';

  @override
  String get tabHistory => 'Historique';

  @override
  String get tabSettings => 'Réglages';

  @override
  String get autoSectionTitle => 'Fond d\'écran automatique';

  @override
  String get statusRunning => 'Actif';

  @override
  String get statusStopped => 'Arrêté';

  @override
  String intervalSummary(int minutes) {
    return 'Change toutes les $minutes min';
  }

  @override
  String nextChangeIn(String time) {
    return 'Prochaine modification dans $time';
  }

  @override
  String get startButton => 'Démarrer';

  @override
  String get stopButton => 'Arrêter';

  @override
  String get changeNowButton => 'Changer maintenant';

  @override
  String get currentWallpaper => 'Fond d\'écran actuel';

  @override
  String get noWallpaperYet => 'Aucun fond d\'écran appliqué pour le moment.';

  @override
  String lastError(String error) {
    return 'Dernière erreur : $error';
  }

  @override
  String get autoStartOnLaunch =>
      'Démarrer automatiquement à l\'ouverture de l\'app';

  @override
  String get searchSectionTitle => 'Recherche enregistrée';

  @override
  String get queryLabel => 'Requête';

  @override
  String get queryHint => 'ex. mountains, +nature -city, @utilisateur';

  @override
  String get categoriesLabel => 'Catégories';

  @override
  String get catGeneral => 'Général';

  @override
  String get catAnime => 'Anime';

  @override
  String get catPeople => 'Personnes';

  @override
  String get purityLabel => 'Classement du contenu';

  @override
  String get purSfw => 'SFW';

  @override
  String get purSketchy => 'Sketchy';

  @override
  String get purNsfw => 'NSFW';

  @override
  String get nsfwNeedsKey =>
      'NSFW nécessite une clé API (ajoutez-la dans Réglages).';

  @override
  String get minResLabel => 'Résolution minimale';

  @override
  String get noMinRes => 'Toutes';

  @override
  String get ratiosLabel => 'Ratio';

  @override
  String get sortingLabel => 'Trier par';

  @override
  String get sortDateAdded => 'Date d\'ajout';

  @override
  String get sortRelevance => 'Pertinence';

  @override
  String get sortRandom => 'Aléatoire';

  @override
  String get sortViews => 'Vues';

  @override
  String get sortFavorites => 'Favoris';

  @override
  String get sortToplist => 'Toplist';

  @override
  String get orderLabel => 'Ordre';

  @override
  String get orderDesc => 'Décroissant';

  @override
  String get orderAsc => 'Croissant';

  @override
  String get topRangeLabel => 'Période du toplist';

  @override
  String get range1d => 'Dernier jour';

  @override
  String get range3d => '3 derniers jours';

  @override
  String get range1w => 'Dernière semaine';

  @override
  String get range1M => 'Dernier mois';

  @override
  String get range3M => '3 derniers mois';

  @override
  String get range6M => '6 derniers mois';

  @override
  String get range1y => 'Dernière année';

  @override
  String get colorLabel => 'Couleur dominante';

  @override
  String get noColor => 'Toutes';

  @override
  String get testSearchButton => 'Tester cette recherche';

  @override
  String get testingLabel => 'Chargement…';

  @override
  String get testResultsTitle => 'Premiers résultats';

  @override
  String get testNoResults =>
      'Aucun fond d\'écran trouvé pour cette recherche.';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get savedMessage => 'Réglages enregistrés.';

  @override
  String searchFailed(String error) {
    return 'Échec de la recherche : $error';
  }

  @override
  String get viewMoreButton => 'Voir tous les résultats';

  @override
  String get galleryTitle => 'Résultats';

  @override
  String get noMoreResults => 'Plus de résultats.';

  @override
  String get downloadButton => 'Télécharger';

  @override
  String downloadDone(String path) {
    return 'Enregistré : $path';
  }

  @override
  String get autoCleanupLabel => 'Nettoyage auto (téléchargements)';

  @override
  String autoCleanupKeep(int count) {
    return 'Garder les $count dernières';
  }

  @override
  String get autoCleanupUnlimited => 'Illimité';

  @override
  String get selectionMode => 'Sélectionner';

  @override
  String get cancelSelection => 'Annuler';

  @override
  String downloadSelected(int count) {
    return 'Télécharger $count';
  }

  @override
  String selectedCount(int count) {
    return '$count sélectionnés';
  }

  @override
  String batchProgress(int done, int total) {
    return 'Téléchargement $done/$total…';
  }

  @override
  String batchDone(int count) {
    return '$count téléchargés';
  }

  @override
  String get startupLabel => 'Lancer au démarrage du système';

  @override
  String get hotkeyLabel =>
      'Raccourci global Ctrl+Alt+W : changer le fond d\'écran';

  @override
  String get sourceLabel => 'Source';

  @override
  String get sourceSearch => 'Recherche enregistrée';

  @override
  String get sourceCollection => 'Collection de l\'utilisateur';

  @override
  String get usernameLabel => 'Nom d\'utilisateur wallhaven';

  @override
  String get loadCollections => 'Charger mes collections';

  @override
  String get collectionsLabel => 'Collection';

  @override
  String get collectionsEmpty => 'Aucune collection trouvée.';

  @override
  String get collectionsNeedKey =>
      'Une clé API est requise pour charger les collections.';

  @override
  String get resolutionsLabel => 'Résolutions exactes';

  @override
  String get allWideChip => 'Tous les paysages';

  @override
  String get allPortraitChip => 'Tous les portraits';

  @override
  String get androidNote =>
      'Sur Android, le fond d\'écran est appliqué à l\'écran d\'accueil.';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get trayShow => 'Afficher';

  @override
  String get trayExit => 'Quitter';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get openInBrowser => 'Ouvrir dans le navigateur';

  @override
  String uploadedBy(String name) {
    return 'Publié par $name';
  }

  @override
  String totalDiskUsage(String size) {
    return '$size sur le disque';
  }

  @override
  String downloadsCount(int count) {
    return '$count téléchargements';
  }

  @override
  String get clearHistory => 'Vider l\'historique';

  @override
  String get deleteFile => 'Supprimer le fichier';

  @override
  String get fileDeleted => 'Fichier supprimé';

  @override
  String get historyCleared => 'Historique vidé';

  @override
  String get historySectionTitle => 'Historique et téléchargements';

  @override
  String get openFolderButton => 'Ouvrir le dossier';

  @override
  String get noHistory => 'Rien de téléchargé pour le moment.';

  @override
  String get reapplyButton => 'Définir comme fond d\'écran';

  @override
  String appliedAt(String date) {
    return 'Appliqué le $date';
  }

  @override
  String get settingsSectionTitle => 'Réglages';

  @override
  String get apiKeyLabel => 'Clé API Wallhaven';

  @override
  String get apiKeyHelper =>
      'Facultative. Débloque le contenu NSFW et vos collections privées. Générez-en une sur wallhaven.cc → Réglages → Compte.';

  @override
  String get intervalLabel => 'Intervalle de changement (minutes)';

  @override
  String get intervalValidation =>
      'Saisissez un nombre entier supérieur ou égal à 1.';

  @override
  String get downloadFolderLabel => 'Dossier de téléchargement';

  @override
  String get chooseFolderButton => 'Choisir…';

  @override
  String get fitLabel => 'Ajustement du fond (Windows)';

  @override
  String get fitFill => 'Remplir';

  @override
  String get fitStretch => 'Étirer';

  @override
  String get fitFit => 'Ajuster';

  @override
  String get fitCenter => 'Centrer';

  @override
  String get fitTile => 'Mosaïque';

  @override
  String get rateNote =>
      'L\'API Wallhaven est limitée à 45 requêtes par minute.';

  @override
  String wallpaperSet(String id) {
    return 'Fond d\'écran défini ($id)';
  }

  @override
  String wallpaperSetFailed(String error) {
    return 'Impossible de définir le fond d\'écran : $error';
  }

  @override
  String wallpaperUnsupported(String platform) {
    return 'La modification du fond d\'écran n\'est pas encore prise en charge sur cette plateforme ($platform).';
  }
}
