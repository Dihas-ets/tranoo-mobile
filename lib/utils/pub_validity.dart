import 'package:tranoo/data/models/pub.dart';

/// Indique si une publicité est encore affichable (statut + dates / durée).
bool isPubValid(Pub pub) {
  if (pub.statut != 'valide') return false;

  final now = DateTime.now();

  if (pub.dateFin != null) {
    return now.isBefore(pub.dateFin!);
  }

  final dateDebut = pub.dateDebut ?? pub.dateDemande;
  final dureeJours = switch (pub.duree.toLowerCase()) {
    '1 semaine' => 7,
    '2 semaines' => 14,
    '1 mois' => 30,
    '2 mois' => 60,
    '3 mois' => 90,
    _ => 7,
  };

  return now.isBefore(dateDebut.add(Duration(days: dureeJours)));
}
