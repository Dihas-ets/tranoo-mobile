import 'package:flutter/material.dart';
import 'package:tranoo/data/models/pub.dart';
import 'package:tranoo/data/repositories/marque_repository.dart';
import 'package:tranoo/data/screens/cars_info.dart';
import 'package:tranoo/data/screens/mastervacpage.dart';

/// Tap sur une pub sponsorisée : charge pub → article → navigation détail.
Future<void> handleMarqueSponsoredPubTap({
  required BuildContext context,
  required Pub pub,
  required MarqueRepository repository,
}) async {
  if (pub.id.isEmpty) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        const Center(child: CircularProgressIndicator()),
  );
  try {
    final pubData = await repository.fetchPubliciteById(pub.id);
    final articleId = pubData['articleId'];
    if (articleId != null && articleId.toString().isNotEmpty) {
      final article = await repository.fetchArticleById(articleId.toString());
      if (!context.mounted) return;
      Navigator.pop(context);
      _openArticleFromPub(context, article);
    } else {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun article lié à cette pub.')),
      );
    }
  } on MarqueFetchException catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  } catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur réseau : $e')),
    );
  }
}

void _openArticleFromPub(BuildContext context, Map<String, dynamic> article) {
  if (article['type'] == 'voiture') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarsInfo(
          titre: article['titre'] ?? '',
          description: article['description'] ?? '',
          marque: article['marque'] ?? '',
          modele: article['modele'] ?? '',
          annee: article['annee'] ?? '',
          prix: article['prix']?.toString() ?? '',
          condition: article['condition'] ?? '',
          boiteVitesse: article['boiteVitesse'] ?? '',
          carburant: article['carburant'] ?? '',
          climatiseur: article['climatiseur'] ?? '',
          distance: article['distance'] ?? '',
          sieges: article['sieges'] ?? '',
          portes: article['portes'] ?? '',
          cylindre: article['cylindre'] ?? '',
          lieu: article['lieu'] ?? '',
          images: (article['photos'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          video: article['video'],
          entreprise: article['entreprise'],
          fromPub: true,
        ),
      ),
    );
  } else if (article['type'] == 'piece') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MastervacPage(
          isAcheteur: true,
          title: article['titre'] ?? '',
          year: article['annee'] ?? '',
          description: article['description'] ?? '',
          company: article['entreprise'] ?? '',
          location: article['localisation'] ?? '',
          price: article['prix']?.toString() ?? '',
          images: (article['photos'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          fuelType: article['typeMoteur'],
          model: article['modele']?.toString(),
          pieceType: article['pieceType'],
          video: article['video'],
          fromPub: true,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Type d'article inconnu.")),
    );
  }
}
