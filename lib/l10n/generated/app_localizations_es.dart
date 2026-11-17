// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Cliente de Wallhaven';

  @override
  String get tabAuto => 'Auto';

  @override
  String get tabSearch => 'Búsqueda';

  @override
  String get tabHistory => 'Historial';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get autoSectionTitle => 'Fondo automático';

  @override
  String get statusRunning => 'Activo';

  @override
  String get statusStopped => 'Detenido';

  @override
  String intervalSummary(int minutes) {
    return 'Cambia cada $minutes min';
  }

  @override
  String nextChangeIn(String time) {
    return 'Próximo cambio en $time';
  }

  @override
  String get startButton => 'Iniciar';

  @override
  String get stopButton => 'Detener';

  @override
  String get changeNowButton => 'Cambiar ahora';

  @override
  String get currentWallpaper => 'Fondo actual';

  @override
  String get noWallpaperYet => 'Todavía no se ha aplicado ningún fondo.';

  @override
  String lastError(String error) {
    return 'Último error: $error';
  }

  @override
  String get autoStartOnLaunch => 'Iniciar automáticamente al abrir la app';

  @override
  String get searchSectionTitle => 'Búsqueda guardada';

  @override
  String get queryLabel => 'Consulta de búsqueda';

  @override
  String get queryHint => 'ej. mountains, +nature -city, @usuario';

  @override
  String get categoriesLabel => 'Categorías';

  @override
  String get catGeneral => 'General';

  @override
  String get catAnime => 'Anime';

  @override
  String get catPeople => 'Personas';

  @override
  String get purityLabel => 'Clasificación de contenido';

  @override
  String get purSfw => 'SFW';

  @override
  String get purSketchy => 'Sketchy';

  @override
  String get purNsfw => 'NSFW';

  @override
  String get nsfwNeedsKey => 'NSFW requiere una API key (añádela en Ajustes).';

  @override
  String get minResLabel => 'Resolución mínima';

  @override
  String get noMinRes => 'Cualquiera';

  @override
  String get ratiosLabel => 'Proporción';

  @override
  String get sortingLabel => 'Ordenar por';

  @override
  String get sortDateAdded => 'Fecha de subida';

  @override
  String get sortRelevance => 'Relevancia';

  @override
  String get sortRandom => 'Aleatorio';

  @override
  String get sortViews => 'Vistas';

  @override
  String get sortFavorites => 'Favoritos';

  @override
  String get sortToplist => 'Toplist';

  @override
  String get orderLabel => 'Orden';

  @override
  String get orderDesc => 'Descendente';

  @override
  String get orderAsc => 'Ascendente';

  @override
  String get topRangeLabel => 'Rango del toplist';

  @override
  String get range1d => 'Último día';

  @override
  String get range3d => 'Últimos 3 días';

  @override
  String get range1w => 'Última semana';

  @override
  String get range1M => 'Último mes';

  @override
  String get range3M => 'Últimos 3 meses';

  @override
  String get range6M => 'Últimos 6 meses';

  @override
  String get range1y => 'Último año';

  @override
  String get colorLabel => 'Color dominante';

  @override
  String get noColor => 'Cualquiera';

  @override
  String get testSearchButton => 'Probar esta búsqueda';

  @override
  String get testingLabel => 'Cargando…';

  @override
  String get testResultsTitle => 'Primeros resultados';

  @override
  String get testNoResults => 'No se encontraron fondos para esta búsqueda.';

  @override
  String get saveButton => 'Guardar';

  @override
  String get savedMessage => 'Ajustes guardados.';

  @override
  String searchFailed(String error) {
    return 'La búsqueda falló: $error';
  }

  @override
  String get viewMoreButton => 'Ver todos los resultados';

  @override
  String get galleryTitle => 'Resultados';

  @override
  String get noMoreResults => 'No hay más resultados.';

  @override
  String get downloadButton => 'Descargar';

  @override
  String downloadDone(String path) {
    return 'Guardado: $path';
  }

  @override
  String get autoCleanupLabel => 'Autolimpieza (descargas)';

  @override
  String autoCleanupKeep(int count) {
    return 'Mantener las últimas $count';
  }

  @override
  String get autoCleanupUnlimited => 'Sin límite';

  @override
  String get startupLabel => 'Ejecutar al iniciar el sistema';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get trayShow => 'Mostrar';

  @override
  String get trayExit => 'Salir';

  @override
  String get tagsLabel => 'Etiquetas';

  @override
  String get openInBrowser => 'Abrir en el navegador';

  @override
  String uploadedBy(String name) {
    return 'Subido por $name';
  }

  @override
  String get historySectionTitle => 'Historial y descargas';

  @override
  String get openFolderButton => 'Abrir carpeta';

  @override
  String get noHistory => 'Todavía no hay nada descargado.';

  @override
  String get reapplyButton => 'Establecer como fondo';

  @override
  String appliedAt(String date) {
    return 'Aplicado el $date';
  }

  @override
  String get settingsSectionTitle => 'Ajustes';

  @override
  String get apiKeyLabel => 'API key de Wallhaven';

  @override
  String get apiKeyHelper =>
      'Opcional. Desbloquea contenido NSFW y tus colecciones privadas. Genera una en wallhaven.cc → Ajustes → Cuenta.';

  @override
  String get intervalLabel => 'Intervalo de cambio (minutos)';

  @override
  String get intervalValidation =>
      'Introduce un número entero mayor o igual a 1.';

  @override
  String get downloadFolderLabel => 'Carpeta de descargas';

  @override
  String get chooseFolderButton => 'Elegir…';

  @override
  String get fitLabel => 'Ajuste del fondo (Windows)';

  @override
  String get fitFill => 'Rellenar';

  @override
  String get fitStretch => 'Estirar';

  @override
  String get fitFit => 'Ajustar';

  @override
  String get fitCenter => 'Centrar';

  @override
  String get fitTile => 'Mosaico';

  @override
  String get rateNote => 'Wallhaven limita la API a 45 peticiones por minuto.';

  @override
  String wallpaperSet(String id) {
    return 'Fondo establecido ($id)';
  }

  @override
  String wallpaperSetFailed(String error) {
    return 'No se pudo establecer el fondo: $error';
  }

  @override
  String wallpaperUnsupported(String platform) {
    return 'Establecer el fondo aún no está soportado en esta plataforma ($platform).';
  }
}
