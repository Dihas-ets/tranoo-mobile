import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tranoo/data/repositories/catalog_repository.dart';

/// Orchestration fetch/cache/auto-refresh pour listes catalogue
/// (voitures / motos / pièces). Precache + messages d'erreur via callbacks.
class CatalogListController extends ChangeNotifier {
  CatalogListController({
    required this.articleType,
    required this.cacheKey,
    required bool Function() isMounted,
    CatalogRepository? repository,
    this.timeout = const Duration(seconds: 8),
    this.autoRefreshInterval = const Duration(seconds: 30),
  })  : _isMounted = isMounted,
        _repository = repository ?? CatalogRepository();

  final String articleType;
  final String cacheKey;
  final Duration timeout;
  final Duration autoRefreshInterval;
  final bool Function() _isMounted;
  final CatalogRepository _repository;

  /// Après items mis à jour (stale ou réseau) — precache images côté UI.
  void Function(List<dynamic> items)? onItemsUpdated;

  /// Map [CatalogFetchException] → message localisé (écran).
  String Function(CatalogFetchException e)? mapError;

  List<dynamic> items = [];
  bool isLoading = true;
  String? error;
  List<bool> isVisible = [];

  Timer? _autoRefreshTimer;

  CatalogRepository get repository => _repository;

  void _notify() {
    if (_isMounted()) notifyListeners();
  }

  void startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(autoRefreshInterval, (_) {
      fetch(silent: true);
    });
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }

  void setVisible(int index, bool visible) {
    if (index < 0 || index >= isVisible.length) return;
    isVisible[index] = visible;
    _notify();
  }

  Future<void> fetch({bool silent = false}) async {
    if (!silent) {
      final stale = await _repository.readStale(cacheKey);
      if (stale != null && _isMounted()) {
        items = stale;
        isVisible = List.generate(stale.length, (_) => true);
        isLoading = false;
        _notify();
        onItemsUpdated?.call(items);
      } else if (_isMounted()) {
        isLoading = true;
        error = null;
        _notify();
      }
    }
    try {
      final data = await _repository.fetchPublicArticles(
        type: articleType,
        cacheKey: cacheKey,
        timeout: timeout,
      );
      if (!_isMounted()) return;
      items = data;
      isVisible = List.generate(data.length, (_) => true);
      isLoading = false;
      error = null;
      _notify();
      onItemsUpdated?.call(items);
    } on CatalogFetchException catch (e) {
      if (!_isMounted()) return;
      error = mapError?.call(e) ?? e.toString();
      isLoading = false;
      _notify();
    }
  }

  Future<void> deleteArticle(String articleId) =>
      _repository.deleteArticle(articleId);
}
