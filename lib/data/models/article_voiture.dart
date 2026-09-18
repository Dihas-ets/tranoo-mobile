class ArticleVoiture {
  final String id;
  final String titre;
  final String description;
  final String marque;
  final String modele;
  final String annee;
  final String prix;
  final String? condition;
  final String? boiteVitesse;
  final String? carburant;
  final String? climatiseur;
  final String? distance;
  final String? sieges;
  final String? portes;
  final String? cylindre;
  final List<String> images;
  final String? video;
  final String? entreprise;
  final String? statut;
  final int views;
  final String? typeMoto;
  final String? typeMoteur;
  final String? puissance;
  final String? transmission;
  final String? demarrage;
  final String? refroidissement;
  final String? capaciteReservoir;
  final String? autonomie;
  final String? disponibilite;
  final bool? garantieConstructeur;
  final String? dureeGarantie;
  final String? kilometrage;
  final List<String> equipements;
  final String? devise;

  ArticleVoiture({
    required this.id,
    required this.titre,
    required this.description,
    required this.marque,
    required this.modele,
    required this.annee,
    required this.prix,
    this.condition,
    this.boiteVitesse,
    this.carburant,
    this.climatiseur,
    this.distance,
    this.sieges,
    this.portes,
    this.cylindre,
    required this.images,
    this.video,
    this.entreprise,
    this.statut,
    this.views = 0,
    this.typeMoto,
    this.typeMoteur,
    this.puissance,
    this.transmission,
    this.demarrage,
    this.refroidissement,
    this.capaciteReservoir,
    this.autonomie,
    this.disponibilite,
    this.garantieConstructeur,
    this.dureeGarantie,
    this.kilometrage,
    this.equipements = const [],
    this.devise,
  });

  Map<String, dynamic> toArticleMap() => {
        '_id': id,
        'titre': titre,
        'description': description,
        'marque': marque,
        'modele': modele,
        'annee': annee,
        'prix': prix,
        'condition': condition,
        'boiteVitesse': boiteVitesse,
        'carburant': carburant,
        'cylindre': cylindre,
        'distance': distance,
        'portes': portes,
        'photos': images,
        'video': video,
        'entreprise': entreprise,
        'views': views,
        if (typeMoto != null) 'typeMoto': typeMoto,
        if (typeMoteur != null) 'typeMoteur': typeMoteur,
        if (puissance != null) 'puissance': puissance,
        if (transmission != null) 'transmission': transmission,
        if (demarrage != null) 'demarrage': demarrage,
        if (refroidissement != null) 'refroidissement': refroidissement,
        if (capaciteReservoir != null) 'capaciteReservoir': capaciteReservoir,
        if (autonomie != null) 'autonomie': autonomie,
        if (disponibilite != null) 'disponibilite': disponibilite,
        'garantieConstructeur': garantieConstructeur ?? false,
        if (dureeGarantie != null) 'dureeGarantie': dureeGarantie,
        if (kilometrage != null) 'kilometrage': kilometrage,
        if (equipements.isNotEmpty) 'equipements': equipements,
        if (devise != null) 'devise': devise,
      };

  factory ArticleVoiture.fromJson(Map<String, dynamic> json) {
    return ArticleVoiture(
      id: json['_id'] ?? '',
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      marque: json['marque'] ?? '',
      modele: json['modele']?.toString() ?? '',
      annee: json['annee'] ?? '',
      prix: json['prix']?.toString() ?? '',
      condition: json['condition'],
      boiteVitesse: json['boiteVitesse'],
      carburant: json['carburant'],
      climatiseur: json['climatiseur'],
      distance: json['distance'],
      sieges: json['sieges'],
      portes: json['portes'],
      cylindre: json['cylindre'],
      images:
          (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      video: json['video'],
      entreprise: json['entreprise'],
      statut: json['statut'],
      views: (json['views'] as num?)?.toInt() ?? 0,
      typeMoto: json['typeMoto']?.toString(),
      typeMoteur: json['typeMoteur']?.toString(),
      puissance: json['puissance']?.toString(),
      transmission: json['transmission']?.toString(),
      demarrage: json['demarrage']?.toString(),
      refroidissement: json['refroidissement']?.toString(),
      capaciteReservoir: json['capaciteReservoir']?.toString(),
      autonomie: json['autonomie']?.toString(),
      disponibilite: json['disponibilite']?.toString(),
      garantieConstructeur: json['garantieConstructeur'] == true,
      dureeGarantie: json['dureeGarantie']?.toString(),
      kilometrage: (json['kilometrage'] ?? json['distance'])?.toString(),
      equipements: (json['equipements'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      devise: json['devise']?.toString(),
    );
  }
}
