import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tranoo/data/models/article.dart';
import 'package:tranoo/data/models/article_voiture.dart';
import 'package:tranoo/data/models/pub.dart';
import 'package:tranoo/data/repositories/marque_repository.dart';

/// État + fetchers catalogue Marque (HTTP via [MarqueRepository]).
/// Les effets UI (precache, carousel) restent côté State via callbacks.
class MarqueCatalogController extends ChangeNotifier {
  MarqueCatalogController({
    required MarqueRepository repository,
    required bool Function() isVendeur,
    required bool Function() isMounted,
  })  : _repository = repository,
        _isVendeur = isVendeur,
        _isMounted = isMounted;

  final MarqueRepository _repository;
  final bool Function() _isVendeur;
  final bool Function() _isMounted;

  /// Après mise à jour pubs « À la une » (cache ou réseau) — carousel + precache.
  void Function(List<Pub> pubs)? onPubsALaUneUpdated;

  /// Precache thumbs / médias après mise à jour des listes.
  void Function(List<Pub> pubs)? onPubsPrecache;
  void Function(List<ArticleVoiture> items)? onVoituresPrecache;
  void Function(List<Article> items)? onPiecesPrecache;

  /// Après fetch réseau pièces / voitures / motos (vues seedées).
  VoidCallback? onCatalogLoaded;

  List<ArticleVoiture> voitures = [];
  bool isLoadingVoitures = true;
  String? errorVoitures;

  List<ArticleVoiture> motos = [];
  bool isLoadingMotos = true;
  String? errorMotos;

  List<Article> pieces = [];
  bool isLoadingPieces = true;
  String? errorPieces;

  List<Pub> pubsSponsorisees = [];
  List<Pub> pubsALaUne = [];
  bool isLoadingPubs = true;
  String? errorPubs;

  /// Vues initiales issues des articles (sync backend ensuite côté State).
  final Map<String, int> backendViews = {};

  void _notify() {
    if (_isMounted()) notifyListeners();
  }

  void seedView(String id, int views) {
    if (id.isEmpty) return;
    backendViews[id] = views;
  }

  void bumpViewOptimistic(String articleId) {
    if (articleId.isEmpty) return;
    backendViews[articleId] = (backendViews[articleId] ?? 0) + 1;
    _notify();
  }

  void setBackendView(String articleId, int views) {
    backendViews[articleId] = views;
    _notify();
  }

  void replaceBackendViews(Map<String, int> next) {
    backendViews
      ..clear()
      ..addAll(next);
    _notify();
  }

  Future<void> primeFromStaleCache() async {
    final isVendeur = _isVendeur();
    final pubs = await _repository.readStalePubsALaUne(isVendeur: isVendeur);
    if (pubs != null && _isMounted()) {
      pubsALaUne = pubs;
      isLoadingPubs = false;
      _notify();
      onPubsALaUneUpdated?.call(pubsALaUne);
    }

    final voituresCached =
        await _repository.readStaleVoitures(isVendeur: isVendeur);
    if (voituresCached != null && _isMounted()) {
      voitures = voituresCached;
      isLoadingVoitures = false;
      _notify();
      onVoituresPrecache?.call(voitures);
    }
  }

  /// Pubs en priorité (visibles en haut) ; le reste est lancé en fire-and-forget.
  Future<void> loadInitial({Future<void> Function()? loadSellerStats}) async {
    await Future.wait<void>([
      fetchPubs(),
      fetchPubsSponsorisees(),
    ]);
    if (!_isMounted()) return;
    unawaited(Future.wait<void>([
      fetchArticlesPieces(),
      fetchVoituresRecommandees(),
      fetchMotosRecommandees(),
      if (loadSellerStats != null) loadSellerStats(),
    ]));
  }

  Future<void> refreshSilent() async {
    await Future.wait<void>([
      fetchArticlesPieces(silent: true),
      fetchVoituresRecommandees(silent: true),
      fetchMotosRecommandees(silent: true),
      fetchPubs(silent: true),
      fetchPubsSponsorisees(silent: true),
    ]);
  }

  Future<void> refreshAll({Future<void> Function()? loadSellerStats}) async {
    await Future.wait<void>([
      fetchArticlesPieces(),
      fetchVoituresRecommandees(),
      fetchMotosRecommandees(),
      fetchPubs(),
      fetchPubsSponsorisees(),
    ]);
    if (loadSellerStats != null) {
      await loadSellerStats();
    }
  }

  Future<void> fetchArticlesPieces({bool silent = false}) async {
    final isVendeur = _isVendeur();
    if (!silent) {
      final cached = await _repository.readStalePieces(isVendeur: isVendeur);
      if (cached != null && _isMounted()) {
        pieces = cached;
        isLoadingPieces = false;
        _notify();
        onPiecesPrecache?.call(pieces);
      } else if (_isMounted()) {
        isLoadingPieces = true;
        errorPieces = null;
        _notify();
      }
    }
    try {
      final next = await _repository.fetchPieces(isVendeur: isVendeur);
      if (!_isMounted()) return;
      pieces = next;
      for (final p in next) {
        seedView(p.id, p.views);
      }
      isLoadingPieces = false;
      _notify();
      onPiecesPrecache?.call(next);
      onCatalogLoaded?.call();
    } on MarqueFetchException catch (e) {
      if (!_isMounted()) return;
      errorPieces = e.message;
      isLoadingPieces = false;
      _notify();
    }
  }

  Future<void> fetchVoituresRecommandees({bool silent = false}) async {
    final isVendeur = _isVendeur();
    if (!silent) {
      final cached = await _repository.readStaleVoitures(isVendeur: isVendeur);
      if (cached != null && _isMounted()) {
        voitures = cached;
        isLoadingVoitures = false;
        _notify();
        onVoituresPrecache?.call(voitures);
      } else if (_isMounted()) {
        isLoadingVoitures = true;
        errorVoitures = null;
        _notify();
      }
    }
    try {
      final next = await _repository.fetchVoitures(isVendeur: isVendeur);
      if (!_isMounted()) return;
      voitures = next;
      for (final v in next) {
        seedView(v.id, v.views);
      }
      isLoadingVoitures = false;
      _notify();
      onVoituresPrecache?.call(next);
      onCatalogLoaded?.call();
    } on MarqueFetchException catch (e) {
      if (!_isMounted()) return;
      errorVoitures = e.message;
      isLoadingVoitures = false;
      _notify();
    }
  }

  Future<void> fetchMotosRecommandees({bool silent = false}) async {
    final isVendeur = _isVendeur();
    if (!silent) {
      final cached = await _repository.readStaleMotos(isVendeur: isVendeur);
      if (cached != null && _isMounted()) {
        motos = cached;
        isLoadingMotos = false;
        _notify();
        onVoituresPrecache?.call(motos);
      } else if (_isMounted()) {
        isLoadingMotos = true;
        errorMotos = null;
        _notify();
      }
    }
    try {
      final next = await _repository.fetchMotos(isVendeur: isVendeur);
      if (!_isMounted()) return;
      motos = next;
      for (final m in next) {
        seedView(m.id, m.views);
      }
      isLoadingMotos = false;
      _notify();
      onVoituresPrecache?.call(next);
      onCatalogLoaded?.call();
    } on MarqueFetchException catch (e) {
      if (!_isMounted()) return;
      errorMotos = e.message;
      isLoadingMotos = false;
      _notify();
    }
  }

  Future<void> fetchPubs({bool silent = false}) async {
    final isVendeur = _isVendeur();
    if (!silent) {
      final cached =
          await _repository.readStalePubsALaUne(isVendeur: isVendeur);
      if (cached != null && _isMounted()) {
        pubsALaUne = cached;
        isLoadingPubs = false;
        _notify();
        onPubsALaUneUpdated?.call(pubsALaUne);
      } else if (_isMounted()) {
        isLoadingPubs = true;
        errorPubs = null;
        _notify();
      }
    }
    try {
      final pubs = await _repository.fetchPubsALaUne(isVendeur: isVendeur);
      if (!_isMounted()) return;
      pubsALaUne = pubs;
      isLoadingPubs = false;
      _notify();
      onPubsALaUneUpdated?.call(pubsALaUne);
    } on MarqueFetchException catch (e) {
      if (!_isMounted()) return;
      errorPubs = e.message;
      isLoadingPubs = false;
      _notify();
    }
  }

  Future<void> fetchPubsSponsorisees({bool silent = false}) async {
    final isVendeur = _isVendeur();
    if (!silent) {
      final cached =
          await _repository.readStalePubsSponsorisees(isVendeur: isVendeur);
      if (cached != null && _isMounted()) {
        pubsSponsorisees = cached;
        isLoadingPubs = false;
        _notify();
        onPubsPrecache?.call(pubsSponsorisees);
      } else if (_isMounted()) {
        isLoadingPubs = true;
        errorPubs = null;
        _notify();
      }
    }
    try {
      final pubs =
          await _repository.fetchPubsSponsorisees(isVendeur: isVendeur);
      if (!_isMounted()) return;
      pubsSponsorisees = pubs;
      isLoadingPubs = false;
      _notify();
      onPubsPrecache?.call(pubsSponsorisees);
    } on MarqueFetchException catch (e) {
      if (!_isMounted()) return;
      errorPubs = e.message;
      isLoadingPubs = false;
      _notify();
    }
  }
}
