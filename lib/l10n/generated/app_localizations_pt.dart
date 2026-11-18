// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Cliente Wallhaven';

  @override
  String get tabAuto => 'Auto';

  @override
  String get tabSearch => 'Busca';

  @override
  String get tabHistory => 'Histórico';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get autoSectionTitle => 'Papel de parede automático';

  @override
  String get statusRunning => 'Em execução';

  @override
  String get statusStopped => 'Parado';

  @override
  String intervalSummary(int minutes) {
    return 'Alterna a cada $minutes min';
  }

  @override
  String nextChangeIn(String time) {
    return 'Próxima troca em $time';
  }

  @override
  String get startButton => 'Iniciar';

  @override
  String get stopButton => 'Parar';

  @override
  String get changeNowButton => 'Trocar agora';

  @override
  String get currentWallpaper => 'Papel de parede atual';

  @override
  String get noWallpaperYet => 'Nenhum papel de parede aplicado ainda.';

  @override
  String lastError(String error) {
    return 'Último erro: $error';
  }

  @override
  String get autoStartOnLaunch => 'Iniciar automaticamente ao abrir o app';

  @override
  String get searchSectionTitle => 'Busca salva';

  @override
  String get queryLabel => 'Consulta de busca';

  @override
  String get queryHint => 'ex.: mountains, +nature -city, @usuário';

  @override
  String get categoriesLabel => 'Categorias';

  @override
  String get catGeneral => 'Geral';

  @override
  String get catAnime => 'Anime';

  @override
  String get catPeople => 'Pessoas';

  @override
  String get purityLabel => 'Classificação de conteúdo';

  @override
  String get purSfw => 'SFW';

  @override
  String get purSketchy => 'Sketchy';

  @override
  String get purNsfw => 'NSFW';

  @override
  String get nsfwNeedsKey =>
      'NSFW requer uma chave de API (adicione em Ajustes).';

  @override
  String get minResLabel => 'Resolução mínima';

  @override
  String get noMinRes => 'Qualquer';

  @override
  String get ratiosLabel => 'Proporção';

  @override
  String get sortingLabel => 'Ordenar por';

  @override
  String get sortDateAdded => 'Data de envio';

  @override
  String get sortRelevance => 'Relevância';

  @override
  String get sortRandom => 'Aleatório';

  @override
  String get sortViews => 'Visualizações';

  @override
  String get sortFavorites => 'Favoritos';

  @override
  String get sortToplist => 'Toplist';

  @override
  String get orderLabel => 'Ordem';

  @override
  String get orderDesc => 'Descendente';

  @override
  String get orderAsc => 'Ascendente';

  @override
  String get topRangeLabel => 'Período do toplist';

  @override
  String get range1d => 'Último dia';

  @override
  String get range3d => 'Últimos 3 dias';

  @override
  String get range1w => 'Última semana';

  @override
  String get range1M => 'Último mês';

  @override
  String get range3M => 'Últimos 3 meses';

  @override
  String get range6M => 'Últimos 6 meses';

  @override
  String get range1y => 'Último ano';

  @override
  String get colorLabel => 'Cor dominante';

  @override
  String get noColor => 'Qualquer';

  @override
  String get testSearchButton => 'Testar esta busca';

  @override
  String get testingLabel => 'Carregando…';

  @override
  String get testResultsTitle => 'Primeiros resultados';

  @override
  String get testNoResults =>
      'Nenhum papel de parede encontrado para esta busca.';

  @override
  String get saveButton => 'Salvar';

  @override
  String get savedMessage => 'Ajustes salvos.';

  @override
  String searchFailed(String error) {
    return 'A busca falhou: $error';
  }

  @override
  String get viewMoreButton => 'Ver todos os resultados';

  @override
  String get galleryTitle => 'Resultados';

  @override
  String get noMoreResults => 'Não há mais resultados.';

  @override
  String get downloadButton => 'Baixar';

  @override
  String downloadDone(String path) {
    return 'Salvo: $path';
  }

  @override
  String get autoCleanupLabel => 'Limpeza automática (downloads)';

  @override
  String autoCleanupKeep(int count) {
    return 'Manter as últimas $count';
  }

  @override
  String get autoCleanupUnlimited => 'Ilimitado';

  @override
  String get selectionMode => 'Selecionar';

  @override
  String get cancelSelection => 'Cancelar';

  @override
  String downloadSelected(int count) {
    return 'Baixar $count';
  }

  @override
  String selectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String batchProgress(int done, int total) {
    return 'Baixando $done/$total…';
  }

  @override
  String batchDone(int count) {
    return '$count baixados';
  }

  @override
  String get startupLabel => 'Iniciar com o sistema';

  @override
  String get hotkeyLabel => 'Atalho global Ctrl+Alt+W: trocar papel de parede';

  @override
  String get sourceLabel => 'Origem';

  @override
  String get sourceSearch => 'Busca salva';

  @override
  String get sourceCollection => 'Coleção do usuário';

  @override
  String get usernameLabel => 'Usuário do wallhaven';

  @override
  String get loadCollections => 'Carregar minhas coleções';

  @override
  String get collectionsLabel => 'Coleção';

  @override
  String get collectionsEmpty => 'Nenhuma coleção encontrada.';

  @override
  String get collectionsNeedKey =>
      'Uma chave de API é necessária para carregar coleções.';

  @override
  String get resolutionsLabel => 'Resoluções exatas';

  @override
  String get allWideChip => 'Todas horizontais';

  @override
  String get allPortraitChip => 'Todas verticais';

  @override
  String get androidNote =>
      'No Android o papel de parede é aplicado à tela inicial.';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get trayShow => 'Mostrar';

  @override
  String get trayExit => 'Sair';

  @override
  String get tagsLabel => 'Etiquetas';

  @override
  String get openInBrowser => 'Abrir no navegador';

  @override
  String uploadedBy(String name) {
    return 'Enviado por $name';
  }

  @override
  String totalDiskUsage(String size) {
    return '$size em disco';
  }

  @override
  String downloadsCount(int count) {
    return '$count downloads';
  }

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get deleteFile => 'Excluir arquivo';

  @override
  String get fileDeleted => 'Arquivo excluído';

  @override
  String get historyCleared => 'Histórico limpo';

  @override
  String get historySectionTitle => 'Histórico e downloads';

  @override
  String get openFolderButton => 'Abrir pasta';

  @override
  String get noHistory => 'Nada baixado ainda.';

  @override
  String get reapplyButton => 'Definir como papel de parede';

  @override
  String appliedAt(String date) {
    return 'Aplicado em $date';
  }

  @override
  String get settingsSectionTitle => 'Ajustes';

  @override
  String get apiKeyLabel => 'Chave de API do Wallhaven';

  @override
  String get apiKeyHelper =>
      'Opcional. Desbloqueia conteúdo NSFW e suas coleções privadas. Gere uma em wallhaven.cc → Ajustes → Conta.';

  @override
  String get intervalLabel => 'Intervalo de troca (minutos)';

  @override
  String get intervalValidation =>
      'Digite um número inteiro maior ou igual a 1.';

  @override
  String get downloadFolderLabel => 'Pasta de downloads';

  @override
  String get chooseFolderButton => 'Escolher…';

  @override
  String get fitLabel => 'Ajuste do papel de parede (Windows)';

  @override
  String get fitFill => 'Preencher';

  @override
  String get fitStretch => 'Esticar';

  @override
  String get fitFit => 'Ajustar';

  @override
  String get fitCenter => 'Centralizar';

  @override
  String get fitTile => 'Mosaico';

  @override
  String get rateNote =>
      'O Wallhaven limita a API a 45 solicitações por minuto.';

  @override
  String wallpaperSet(String id) {
    return 'Papel de parede definido ($id)';
  }

  @override
  String wallpaperSetFailed(String error) {
    return 'Não foi possível definir o papel de parede: $error';
  }

  @override
  String wallpaperUnsupported(String platform) {
    return 'Definir o papel de parede ainda não é suportado nesta plataforma ($platform).';
  }
}
