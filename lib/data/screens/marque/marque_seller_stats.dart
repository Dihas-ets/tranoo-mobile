import 'package:flutter/material.dart';
import 'package:tranoo/data/models/article.dart';
import 'package:tranoo/data/models/article_voiture.dart';
import 'package:tranoo/utils/catalog_display.dart';
import 'package:tranoo/widgets/seller_stats_dashboard.dart';

/// Tableau de bord stats vendeur (onglet Statistiques).
class MarqueSellerStatsSection extends StatelessWidget {
  const MarqueSellerStatsSection({
    super.key,
    required this.isVendeur,
    required this.vendeurType,
    required this.voitures,
    required this.motos,
    required this.pieces,
    required this.backendViews,
    required this.vehiclesOnline,
    required this.piecesOnline,
    required this.vehiclesSold,
    required this.piecesSold,
    required this.isLoading,
  });

  final bool isVendeur;
  final String? vendeurType;
  final List<ArticleVoiture> voitures;
  final List<ArticleVoiture> motos;
  final List<Article> pieces;
  final Map<String, int> backendViews;
  final int vehiclesOnline;
  final int piecesOnline;
  final int vehiclesSold;
  final int piecesSold;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isVendeur) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: const Text(
            "Les statistiques détaillées sont réservées aux vendeurs.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF795548),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final vt = (vendeurType ?? 'mixte').toLowerCase().trim();
    final showVehicules =
        vt.isEmpty || vt == 'mixte' || vt == 'vehicules' || vt == 'véhicules';
    final showPieces = vt.isEmpty || vt == 'mixte' || vt == 'pieces';
    final showMotos = vt == 'motos';

    final motosEnLigne = motos
        .where(
          (m) =>
              (m.statut ?? 'en_ligne') == 'en_ligne' &&
              (m.statut ?? '') != 'vendu',
        )
        .length;

    final totalViewsVehicles = voitures.fold<int>(
      0,
      (sum, v) => sum + (backendViews[v.id] ?? 0),
    );
    final totalViewsMotos = motos.fold<int>(
      0,
      (sum, m) => sum + (backendViews[m.id] ?? 0),
    );
    final totalViewsPieces = pieces.fold<int>(
      0,
      (sum, p) => sum + (backendViews[p.id] ?? 0),
    );
    final totalViews = totalViewsVehicles + totalViewsMotos + totalViewsPieces;

    final statsCards = <Map<String, Object?>>[
      if (showVehicules)
        {
          'label': 'Véhicules en ligne',
          'value': vehiclesOnline,
          'icon': Icons.directions_car_filled,
          'color': const Color(0xFFF8BF13),
        },
      if (showMotos)
        {
          'label': 'Motos en ligne',
          'value': motosEnLigne,
          'icon': Icons.two_wheeler,
          'color': const Color(0xFFF8BF13),
        },
      if (showPieces)
        {
          'label': 'Pièces en ligne',
          'value': piecesOnline,
          'icon': Icons.build_circle_outlined,
          'color': const Color(0xFFF8BF13),
        },
      if (showVehicules)
        {
          'label': 'Véhicules vendus',
          'value': vehiclesSold,
          'icon': Icons.sell_outlined,
          'color': const Color(0xFF2E7D32),
        },
      if (showPieces)
        {
          'label': 'Pièces vendues',
          'value': piecesSold,
          'icon': Icons.handyman_outlined,
          'color': const Color(0xFF2E7D32),
        },
      {
        'label': 'Vues enregistrées',
        'value': totalViews,
        'icon': Icons.remove_red_eye,
        'color': const Color(0xFFF8BF13),
      },
    ];

    final viewPoints = <double>[
      ...voitures.map((v) => (backendViews[v.id] ?? 0).toDouble()),
      ...motos.map((m) => (backendViews[m.id] ?? 0).toDouble()),
      ...pieces.map((p) => (backendViews[p.id] ?? 0).toDouble()),
    ]..sort((a, b) => b.compareTo(a));
    while (viewPoints.length < 8) {
      viewPoints.add(0);
    }
    final activityPoints = viewPoints.take(8).toList().reversed.toList();

    final dashboardKpis = statsCards.take(4).map((card) {
      final valueNum = (card['value'] as num?)?.round() ?? 0;
      return SellerStatsKpi(
        label: card['label'] as String,
        value: '$valueNum',
        icon: card['icon'] as IconData,
        color: card['color'] as Color,
      );
    }).toList();

    final donutSlices = <SellerStatsDonutSlice>[
      if (showVehicules && totalViewsVehicles > 0)
        SellerStatsDonutSlice(
          label: 'Véhicules',
          value: totalViewsVehicles.toDouble(),
          color: const Color(0xFFF8BF13),
        ),
      if (showMotos && totalViewsMotos > 0)
        SellerStatsDonutSlice(
          label: 'Motos',
          value: totalViewsMotos.toDouble(),
          color: const Color(0xFF1565C0),
        ),
      if (showPieces && totalViewsPieces > 0)
        SellerStatsDonutSlice(
          label: 'Pièces',
          value: totalViewsPieces.toDouble(),
          color: const Color(0xFF5D4037),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vos statistiques",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (isLoading) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(minHeight: 3),
          ],
          const SizedBox(height: 12),
          SellerStatsDashboard(
            activityTitle: 'Activité (vues)',
            activitySubtitle: 'Répartition par annonces les plus consultées',
            activityPoints: activityPoints,
            kpis: dashboardKpis,
            donutTitle: 'Répartition des vues',
            donutCenterValue: formatCompactCount(totalViews),
            donutCenterLabel: 'Vues totales',
            donutSlices: donutSlices.isNotEmpty
                ? donutSlices
                : const [
                    SellerStatsDonutSlice(
                      label: 'Aucune vue',
                      value: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}
