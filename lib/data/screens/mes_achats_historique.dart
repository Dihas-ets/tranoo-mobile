import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/cars_info.dart';
import 'package:tranoo/data/screens/transitaires_list_page.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/services/transit_mission_service.dart';
import 'package:tranoo/utils/tranoo_toast.dart';
import 'package:tranoo/widgets/transitaire_carousel_section.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';

class MesAchatsHistoriquePage extends StatefulWidget {
  final String? highlightArticleId;

  const MesAchatsHistoriquePage({super.key, this.highlightArticleId});

  @override
  State<MesAchatsHistoriquePage> createState() =>
      _MesAchatsHistoriquePageState();
}

class _MesAchatsHistoriquePageState extends State<MesAchatsHistoriquePage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _parcours = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await TransitMissionService.instance.listMesParcours();
      if (!mounted) return;
      setState(() => _parcours = list);
      if (widget.highlightArticleId != null) {
        final match = list.where((p) {
          final article = p['article'];
          final id =
              article is Map ? article['_id']?.toString() : article?.toString();
          return id == widget.highlightArticleId;
        });
        if (match.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _openDetail(match.first);
          });
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context)!.purchaseHistoryLoadError;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(dynamic raw) {
    final dt = DateTime.tryParse(raw?.toString() ?? '');
    if (dt == null) return '--';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _statusLabel(AppLocalizations l10n, String statut) {
    switch (statut) {
      case 'en_cours':
        return l10n.purchaseStatusEnCours;
      case 'transferer':
        return l10n.purchaseStatusTransferer;
      case 'traite':
        return l10n.purchaseStatusTraite;
      case 'annule':
        return l10n.purchaseStatusAnnule;
      default:
        return l10n.purchaseStatusParcours;
    }
  }

  Color _statusColor(String statut) {
    switch (statut) {
      case 'traite':
        return const Color(0xFF16A34A);
      case 'annule':
        return const Color(0xFFB3261E);
      case 'transferer':
        return const Color(0xFF1B2B4B);
      case 'en_cours':
        return const Color(0xFFF8BF13);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _articleTitle(Map<String, dynamic> mission) {
    final article = mission['article'];
    if (article is Map) {
      final titre = (article['titre'] ?? '').toString().trim();
      if (titre.isNotEmpty) return titre;
      final composed =
          '${article['marque'] ?? ''} ${article['modele'] ?? ''}'.trim();
      if (composed.isNotEmpty) return composed;
    }
    return (mission['articleTitre'] ?? 'Véhicule').toString();
  }

  String? _articleId(Map<String, dynamic> mission) {
    final article = mission['article'];
    if (article is Map) return article['_id']?.toString();
    return article?.toString();
  }

  String? _articleImage(Map<String, dynamic> mission) {
    final article = mission['article'];
    if (article is Map && article['photos'] is List) {
      final photos = article['photos'] as List;
      if (photos.isNotEmpty) return photos.first?.toString();
    }
    return null;
  }

  void _openVehicle(Map<String, dynamic> mission) {
    final article = mission['article'];
    if (article is! Map) return;
    final photos = (article['photos'] is List)
        ? (article['photos'] as List)
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarsInfo(
          id: article['_id']?.toString(),
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
        ),
      ),
    );
  }

  Future<void> _changeTransitaire(Map<String, dynamic> mission) async {
    final articleId = _articleId(mission);
    if (articleId == null) return;
    if (mission['canChangeTransitaire'] != true) {
      showTranooToast(
        context,
        message: AppLocalizations.of(context)!.errorTransitaireActif,
        isError: true,
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: kTransitaireFlowRoute,
        builder: (_) => TransitairesListPage(
          articleId: articleId,
          onSelectSuccess: () {
            if (!mounted) return;
            showTranooToast(
              context,
              message: AppLocalizations.of(context)!.purchaseForwarderSelected,
              isSuccess: true,
            );
            _load();
          },
        ),
      ),
    );
    if (mounted) _load();
  }

  void _openDetail(Map<String, dynamic> mission) {
    final l10n = AppLocalizations.of(context)!;
    final statut = (mission['statut'] ?? 'parcours').toString();
    final transitaire = mission['transitaire'];
    final transitaireNom = transitaire is Map
        ? '${transitaire['prenoms'] ?? ''} ${transitaire['nom'] ?? ''}'.trim()
        : '';
    final mode = (mission['modeLivraison'] ?? '').toString() == 'consommation'
        ? l10n.purchaseModeConsommation
        : l10n.purchaseModeTransit;
    final canChange = mission['canChangeTransitaire'] == true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.paddingOf(ctx).bottom;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.purchaseHistoryDetailsTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kTransitaireNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(statut).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(l10n, statut),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _statusColor(statut),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _detailRow(l10n.purchaseHistoryModeLabel, mode),
                    _detailRow(
                      l10n.purchaseHistoryDestinationLabel,
                      (mission['paysDestination'] ?? '—').toString(),
                    ),
                    if ((mission['detailsSupplementaires'] ?? '')
                        .toString()
                        .trim()
                        .isNotEmpty)
                      _detailRow(
                        l10n.purchaseHistoryDetailsLabel,
                        mission['detailsSupplementaires'].toString(),
                      ),
                    _detailRow(
                      l10n.purchaseHistoryForwarderLabel,
                      transitaireNom.isNotEmpty
                          ? transitaireNom
                          : l10n.purchaseHistoryNoForwarder,
                    ),
                    const SizedBox(height: 20),
                    if (canChange)
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _changeTransitaire(mission);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kTransitaireNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.purchaseHistoryChangeForwarder),
                        ),
                      ),
                    if (canChange) const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openVehicle(mission);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kTransitaireNavy,
                          side: const BorderSide(color: kTransitaireAmber),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.purchaseHistoryViewVehicle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTransitaireNavy,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: Colors.black,
        title: Text(
          l10n.purchaseHistoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _parcours.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.purchaseHistoryEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _parcours.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final mission = _parcours[index];
                          final statut =
                              (mission['statut'] ?? 'parcours').toString();
                          final image = _articleImage(mission);
                          final transitaire = mission['transitaire'];
                          final transitaireNom = transitaire is Map
                              ? '${transitaire['prenoms'] ?? ''} ${transitaire['nom'] ?? ''}'
                                  .trim()
                              : '';
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: () => _openDetail(mission),
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: image != null
                                          ? TranooNetworkImage(
                                              url: image,
                                              width: 72,
                                              height: 72,
                                              fit: BoxFit.cover,
                                              cloudinaryWidthPx:
                                                  cloudinaryWidthPx(
                                                context,
                                                logicalWidth: 72,
                                              ),
                                            )
                                          : _placeholderThumb(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _articleTitle(mission),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            transitaireNom.isNotEmpty
                                                ? transitaireNom
                                                : l10n
                                                    .purchaseHistoryNoForwarder,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            l10n.purchaseHistoryStartedAt(
                                              _formatDate(mission['createdAt']),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 82,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(statut)
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _statusLabel(l10n, statut),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            height: 1.15,
                                            color: _statusColor(statut),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade200,
      child: const Icon(Icons.directions_car_outlined, color: Colors.grey),
    );
  }
}

/// Navigation utilitaire depuis les notifications.
void openPurchaseHistory(
  BuildContext context, {
  String? articleId,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MesAchatsHistoriquePage(highlightArticleId: articleId),
    ),
  );
}
