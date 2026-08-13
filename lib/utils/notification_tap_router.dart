import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tranoo/data/screens/cars_info.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/data/screens/mastervacpage.dart';
import 'package:tranoo/data/screens/mes_achats_historique.dart';
import 'package:tranoo/data/screens/mesfactures.dart';
import 'package:tranoo/data/screens/moto_info.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/transit.dart';
import 'package:tranoo/data/screens/wallet_screen.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/in_app_delivery_popup.dart';
import 'package:tranoo/utils/tranoo_toast.dart';

/// Redirection au clic (push + listing in-app) selon le type de notification.
class NotificationTapRouter {
  NotificationTapRouter._();

  static String? mongoId(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final v = raw.trim();
      if (v.isEmpty || v == 'null' || v == 'undefined') return null;
      return v;
    }
    if (raw is Map) {
      return mongoId(raw['_id'] ?? raw['id'] ?? raw[r'$oid'] ?? raw['oid']);
    }
    final v = raw.toString().trim();
    if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(v)) return v;
    return null;
  }

  static Map<String, String> dataFromRemoteMessage(RemoteMessage message) {
    return message.data.map(
      (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
    );
  }

  static Map<String, String> dataFromNotification(Map<String, dynamic> notif) {
    final data = <String, String>{};
    final nested = notif['data'];
    if (nested is Map) {
      nested.forEach((k, v) {
        if (v != null) data[k.toString()] = v.toString();
      });
    }
    data['type'] = (notif['type'] ?? data['type'] ?? 'general').toString();
    data['notificationId'] =
        (notif['_id'] ?? notif['id'] ?? data['notificationId'] ?? '').toString();
    final related = notif['relatedId'];
    final relatedId = mongoId(related);
    if (relatedId != null) data['relatedId'] = relatedId;
    if ((data['targetArticleId'] ?? '').isEmpty) {
      data['targetArticleId'] = data['relatedId'] ?? '';
    }
    data['relatedModel'] =
        (notif['relatedModel'] ?? data['relatedModel'] ?? '').toString();
    data['action'] = (data['action'] ?? '').toString();
    return data;
  }

  static Map<String, dynamic> seedArticleFromData(Map<String, String> data) {
    final id = articleIdFrom(data) ?? '';
    final thumb = (data['thumbnailUrl'] ?? '').trim();
    var type = (data['targetType'] ?? '').toLowerCase();
    final path = (data['targetPath'] ?? '').toLowerCase();
    if (type.isEmpty) {
      if (path.contains('moto')) {
        type = 'moto';
      } else if (path.contains('mastervac') || path.contains('piece')) {
        type = 'piece';
      } else {
        type = 'voiture';
      }
    }
    return {
      '_id': id,
      'type': type,
      'titre': data['articleTitle'] ?? data['title'] ?? '',
      if (thumb.isNotEmpty) 'photos': [thumb],
    };
  }

  static Map<String, dynamic> articleMapFromNotification(
    Map<String, dynamic> notif,
  ) {
    final related = notif['relatedId'];
    if (related is Map) {
      final map = Map<String, dynamic>.from(related);
      final hasBody = map['titre'] != null ||
          map['photos'] != null ||
          map['type'] != null ||
          map['marque'] != null;
      if (hasBody) return map;
    }
    return seedArticleFromData(dataFromNotification(notif));
  }

  static bool opensArticleDetail(Map<String, String> data) {
    final type = (data['type'] ?? '').toLowerCase();
    final action = (data['action'] ?? '').toLowerCase();
    if (type == 'new_article' || type == 'proposition_alerte') return true;
    if (action == 'view_article' ||
        action == 'view_my_article' ||
        action == 'view_proposal' ||
        action == 'article_rejected') {
      return true;
    }
    return false;
  }

  static String? articleIdFrom(Map<String, String> data) {
    for (final key in ['targetArticleId', 'relatedId', 'articleId']) {
      final v = mongoId(data[key]);
      if (v != null) return v;
    }
    return null;
  }

  static Future<void> openFromRemoteMessage(
    BuildContext? context,
    RemoteMessage message, {
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return openFromData(
      context,
      dataFromRemoteMessage(message),
      navigatorKey: navigatorKey,
    );
  }

  static Future<void> openFromNotification(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    return openFromData(
      context,
      dataFromNotification(notification),
      initialArticle: articleMapFromNotification(notification),
    );
  }

  static Future<NavigatorState?> _resolveNavigator({
    BuildContext? context,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    NavigatorState? nav = navigatorKey?.currentState;
    if (nav != null) return nav;
    final ctx = context ?? navigatorKey?.currentContext;
    if (ctx != null) return Navigator.of(ctx, rootNavigator: true);
    if (navigatorKey == null) return null;
    for (var i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      nav = navigatorKey.currentState;
      if (nav != null) return nav;
    }
    return null;
  }

  static Future<void> openFromData(
    BuildContext? context,
    Map<String, String> data, {
    GlobalKey<NavigatorState>? navigatorKey,
    Map<String, dynamic>? initialArticle,
  }) async {
    final nav = await _resolveNavigator(
      context: context,
      navigatorKey: navigatorKey,
    );
    if (nav == null) return;

    void push(Widget page) {
      nav.push(MaterialPageRoute(builder: (_) => page));
    }

    final type = (data['type'] ?? 'general').toLowerCase();
    final eventType = (data['eventType'] ?? '').toLowerCase();

    if (type == 'otp') return;

    if (type == 'delivery' &&
        eventType == 'arrived' &&
        (data['relatedId'] ?? '').isNotEmpty) {
      InAppDeliveryPopup.showLivreurArrived(
        deliveryId: data['relatedId']!,
      );
      return;
    }

    if (opensArticleDetail(data) || type == 'publicite') {
      final seed = initialArticle ?? seedArticleFromData(data);
      final id = mongoId(seed['_id']) ?? articleIdFrom(data);
      if (id != null) {
        seed['_id'] = id;
        push(_ArticleDetailPage(
          article: seed,
          typeHint: data['targetType'] ?? data['targetPath'],
          allowOfflineView: canViewOfflineArticle(seed, data),
        ));
        return;
      }
    }

    switch (type) {
      case 'verification':
      case 'verification_result':
      case 'alerte':
      case 'promotion':
        push(Notifications(openNotificationId: data['notificationId']));
        return;
      case 'paiement':
        push(const MesFacturesPage());
        return;
      case 'delivery':
        push(const WalletScreen());
        return;
      case 'transit_selection':
      case 'transit_transfer':
      case 'transit_rejected':
        push(const Transit());
        return;
      case 'transit_purchase_cancelled':
        push(const MesAchatsHistoriquePage());
        return;
      default:
        push(Notifications(openNotificationId: data['notificationId']));
    }
  }

  static Future<void> openArticleDetails(
    BuildContext context, {
    required String articleId,
    String? typeHint,
    Map<String, dynamic>? article,
  }) async {
    if (!context.mounted) return;
    final seed = article ??
        {'_id': articleId, if (typeHint != null) 'type': typeHint};
    seed['_id'] = articleId;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => _ArticleDetailPage(
          article: seed,
          typeHint: typeHint,
          allowOfflineView: isCurrentUserSeller(seed),
        ),
      ),
    );
  }

  static bool isCurrentUserSeller(Map<String, dynamic> article) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final candidates = <String>[];
    final vendeur = article['vendeur'];
    void addCandidate(dynamic raw) {
      final id = mongoId(raw);
      if (id != null) {
        candidates.add(id.toLowerCase());
        return;
      }
      final s = raw?.toString().trim().toLowerCase() ?? '';
      if (s.isNotEmpty && s != 'null') candidates.add(s);
    }

    if (vendeur is Map) {
      addCandidate(vendeur['_id']);
      addCandidate(vendeur['id']);
      addCandidate(vendeur['uid']);
      addCandidate(vendeur['firebaseUid']);
      addCandidate(vendeur['email']);
    } else {
      addCandidate(vendeur);
    }

    if (candidates.contains(user.uid.toLowerCase())) return true;
    final email = user.email?.trim().toLowerCase();
    return email != null && email.isNotEmpty && candidates.contains(email);
  }

  static bool canViewOfflineArticle(
    Map<String, dynamic> article,
    Map<String, String> data,
  ) {
    final action = (data['action'] ?? '').toLowerCase();
    final audience = (data['audience'] ?? '').toLowerCase();
    if (action == 'view_my_article' || audience == 'seller') return true;
    return isCurrentUserSeller(article);
  }

  static bool isArticleListed(Map<String, dynamic> article) {
    final statut = (article['statut'] ?? '').toString().toLowerCase();
    final vente = (article['statutVente'] ?? '').toString().toLowerCase();
    if (vente == 'vendu' || statut == 'vendu') return false;
    if (statut == 'rejeté' || statut == 'rejete' || statut == 'en_attente') {
      return false;
    }
    if (statut.isEmpty) return true;
    return statut == 'en_ligne';
  }

  static Widget detailPageFromArticle(
    Map<String, dynamic> article, {
    String? typeHint,
  }) {
    final hint = (typeHint ?? '').toLowerCase();
    final articleType = (article['type'] ?? '').toString().toLowerCase();
    final isMoto = articleType == 'moto' || hint.contains('moto');
    final isPiece = articleType == 'piece' ||
        hint.contains('piece') ||
        hint.contains('mastervac');

    if (isPiece) {
      return MastervacPage(
        id: mongoId(article['_id']) ?? article['_id']?.toString(),
        isAcheteur: true,
        title: (article['titre'] ?? '').toString(),
        year: (article['annee'] ?? '').toString(),
        description: (article['description'] ?? '').toString(),
        company: (article['entreprise'] ?? '').toString(),
        location: (article['lieu'] ?? article['localisation'] ?? '').toString(),
        price: (article['prix'] ?? '').toString(),
        fuelType: article['typeMoteur']?.toString(),
        model: article['modele']?.toString(),
        pieceType: (article['pieceType'] ?? article['condition'])?.toString(),
        images: (article['photos'] is List)
            ? (article['photos'] as List).map((e) => e?.toString()).toList()
            : const [],
        video: article['video']?.toString(),
        fournisseur: article['fournisseur'] is Map
            ? Map<String, dynamic>.from(article['fournisseur'] as Map)
            : null,
        vendeur: article['vendeur'] is Map
            ? Map<String, dynamic>.from(article['vendeur'] as Map)
            : null,
      );
    }
    if (isMoto) {
      return MotoInfo.fromArticleMap(article);
    }
    final photos = (article['photos'] is List)
        ? (article['photos'] as List)
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];
    return CarsInfo(
      id: mongoId(article['_id']) ?? article['_id']?.toString(),
      titre: article['titre']?.toString(),
      description: article['description']?.toString(),
      marque: article['marque']?.toString(),
      modele: article['modele']?.toString(),
      annee: article['annee']?.toString(),
      prix: article['prix']?.toString(),
      condition: article['condition']?.toString(),
      boiteVitesse: article['boiteVitesse']?.toString(),
      carburant: article['carburant']?.toString(),
      climatiseur: article['climatiseur']?.toString(),
      distance: article['distance']?.toString(),
      sieges: article['sieges']?.toString(),
      portes: article['portes']?.toString(),
      cylindre: article['cylindre']?.toString(),
      couleur: article['couleur']?.toString(),
      dedouanement: article['dedouanement'] == true,
      lieu: (article['lieu'] ?? article['localisation'])?.toString(),
      images: photos,
      videos: const [],
      video: article['video']?.toString(),
      entreprise: article['entreprise']?.toString(),
    );
  }
}

class _ArticleDetailPage extends StatefulWidget {
  final Map<String, dynamic> article;
  final String? typeHint;
  final bool allowOfflineView;

  const _ArticleDetailPage({
    required this.article,
    this.typeHint,
    this.allowOfflineView = false,
  });

  @override
  State<_ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<_ArticleDetailPage> {
  late Map<String, dynamic> _article;
  bool _warnedUnavailable = false;
  bool _blocked = false;

  bool get _statutKnown {
    final s = (_article['statut'] ?? '').toString().trim();
    return s.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _article = Map<String, dynamic>.from(widget.article);
    if (_statutKnown &&
        !NotificationTapRouter.isArticleListed(_article) &&
        !widget.allowOfflineView) {
      _blocked = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_blocked) {
        _warnUnavailable();
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        return;
      }
      if (!NotificationTapRouter.isArticleListed(_article)) {
        _warnUnavailable();
      }
      _hydrate();
    });
  }

  void _warnUnavailable() {
    if (!mounted || _warnedUnavailable) return;
    _warnedUnavailable = true;
    final l10n = AppLocalizations.of(context);
    showTranooToast(
      context,
      message: l10n?.articleNoLongerOnline ??
          'Cette annonce n\'est plus en ligne.',
      isError: true,
    );
  }

  void _blockAndLeave() {
    if (!mounted) return;
    _warnUnavailable();
    if (_blocked) return;
    setState(() => _blocked = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _hydrate() async {
    final id = NotificationTapRouter.mongoId(_article['_id']);
    if (id == null) return;
    String? token;
    try {
      token = await FirebaseAuth.instance.currentUser
          ?.getIdToken()
          .timeout(const Duration(seconds: 2));
    } catch (_) {}
    final urls = [
      '${getBaseUrl()}/articles/$id',
      '${getBaseUrl()}/public/articles/$id',
    ];
    var saw404 = false;
    var fetched = false;
    for (final url in urls) {
      try {
        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 404) {
          saw404 = true;
          continue;
        }
        if (response.statusCode != 200) continue;
        final decoded = jsonDecode(response.body);
        if (decoded is! Map) continue;
        fetched = true;
        final live = Map<String, dynamic>.from(decoded);
        if (!mounted) return;
        final seller = widget.allowOfflineView ||
            NotificationTapRouter.isCurrentUserSeller(live);
        if (!NotificationTapRouter.isArticleListed(live) && !seller) {
          _blockAndLeave();
          return;
        }
        setState(() => _article = live);
        if (!NotificationTapRouter.isArticleListed(live)) {
          _warnUnavailable();
        }
        return;
      } catch (_) {}
    }
    if (!fetched && saw404 && !widget.allowOfflineView) {
      _blockAndLeave();
    } else if (!fetched && saw404) {
      _warnUnavailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_blocked) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.shrink(),
      );
    }
    return NotificationTapRouter.detailPageFromArticle(
      _article,
      typeHint: widget.typeHint,
    );
  }
}
