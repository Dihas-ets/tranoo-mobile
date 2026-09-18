class Pub {
  final String id;
  final String? articleId;
  final String description;
  final String typePub;
  final String statut;
  final String duree;
  final DateTime dateDemande;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final List<String> media;
  final String? lien;

  Pub({
    required this.id,
    this.articleId,
    required this.description,
    required this.typePub,
    required this.statut,
    required this.duree,
    required this.dateDemande,
    this.dateDebut,
    this.dateFin,
    required this.media,
    this.lien,
  });

  factory Pub.fromJson(Map<String, dynamic> json) {
    final dynamic rawArticleId = json['articleId'];
    final String? parsedArticleId = rawArticleId is Map<String, dynamic>
        ? rawArticleId['_id']?.toString()
        : rawArticleId?.toString();
    return Pub(
      id: json['_id'] ?? '',
      articleId: parsedArticleId,
      description: json['description'] ?? '',
      typePub: json['typePub'] ?? '',
      statut: json['statut'] ?? '',
      duree: json['duree'] ?? '',
      dateDemande:
          DateTime.tryParse(json['dateDemande'] ?? '') ?? DateTime.now(),
      dateDebut: DateTime.tryParse(json['dateDebut'] ?? ''),
      dateFin: DateTime.tryParse(json['dateFin'] ?? ''),
      media: (json['media'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lien: json['lien'],
    );
  }
}
