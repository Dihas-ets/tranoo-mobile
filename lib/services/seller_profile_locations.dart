import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';

/// Localisations vendeur / fournisseur enregistrées à l'inscription (profil).
class SellerProfileLocations {
  final String telephone;
  final String sellerAddress;
  final String sellerCity;
  final double? sellerLat;
  final double? sellerLng;
  final String fournisseurTel;
  final String fournisseurAddress;
  final String fournisseurCity;
  final double? fournisseurLat;
  final double? fournisseurLng;

  const SellerProfileLocations({
    required this.telephone,
    required this.sellerAddress,
    required this.sellerCity,
    this.sellerLat,
    this.sellerLng,
    required this.fournisseurTel,
    required this.fournisseurAddress,
    required this.fournisseurCity,
    this.fournisseurLat,
    this.fournisseurLng,
  });

  static Future<SellerProfileLocations?> load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      final resp = await Dio(
        BaseOptions(
          baseUrl: UserService().dio.options.baseUrl,
          headers: {'Authorization': 'Bearer $token'},
        ),
      ).get('/protected/me');
      final u = resp.data['user'];
      if (u is! Map) return null;
      final map = Map<String, dynamic>.from(u as Map);
      final tel = (map['telephone'] ?? '').toString().trim();
      final adresse = (map['adresse'] ?? '').toString().trim();
      final ville = (map['ville'] ?? '').toString().trim();
      double? lat;
      double? lng;
      final loc = map['location'];
      if (loc is Map && loc['coordinates'] is List) {
        final coords = loc['coordinates'] as List;
        if (coords.length >= 2) {
          lng = (coords[0] as num?)?.toDouble();
          lat = (coords[1] as num?)?.toDouble();
        }
      }
      final fp = map['fournisseurProfil'];
      Map<String, dynamic> fournisseur = {};
      if (fp is Map) fournisseur = Map<String, dynamic>.from(fp);
      final fTel = (fournisseur['telephone'] ?? tel).toString().trim();
      final fAddr = (fournisseur['adresseTexte'] ?? adresse).toString().trim();
      final fVille = (fournisseur['ville'] ?? ville).toString().trim();
      final fLat = fournisseur['latitude'];
      final fLng = fournisseur['longitude'];
      return SellerProfileLocations(
        telephone: tel,
        sellerAddress: adresse,
        sellerCity: ville,
        sellerLat: lat,
        sellerLng: lng,
        fournisseurTel: fTel,
        fournisseurAddress: fAddr,
        fournisseurCity: fVille,
        fournisseurLat: fLat is num ? fLat.toDouble() : double.tryParse('$fLat'),
        fournisseurLng: fLng is num ? fLng.toDouble() : double.tryParse('$fLng'),
      );
    } catch (_) {
      return null;
    }
  }
}
