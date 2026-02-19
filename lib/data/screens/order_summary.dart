import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feexpay_flutter/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:tranoo/services/cart_service.dart';
import 'package:tranoo/services/user_service.dart';
import '../../config/backend_config.dart';
import 'package:tranoo/providers/counter_provider.dart';

enum PaymentMethod { cash, online }

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  double _deliveryFee = 720; // Calculé automatiquement
  bool _isProcessing = false;
  final String _transKey = randomAlphaNumeric(15);
  
  // Variables pour les dropdowns dynamiques
  String? _selectedDepartement;
  String? _selectedCommune;
  String? _selectedVille;
  String? _selectedQuartier;
  double? _deliveryLatitude;
  double? _deliveryLongitude;
  
  // États de chargement
  bool _isLoadingDepartements = false;
  bool _isLoadingCommunes = false;
  bool _isLoadingVilles = false;
  bool _isLoadingQuartiers = false;
  bool _isCalculatingDeliveryFee = false;
  
  // Hiérarchie Benin – chargée via nouvelle API
  final List<Map<String, dynamic>> _departementsBenin = [];
  final Map<String, List<Map<String, dynamic>>> _communesParDepartement = {};
  final Map<String, List<String>> _villesParCommune = {};
  final Map<String, List<String>> _quartiersParVille = {};
  
  // Quartiers réels pour les villes principales
  final Map<String, List<String>> _quartiersReels = {
    // Cotonou
    "Cotonou 1": ["Agla", "Ahouansori", "Akpakpa", "Fidjrossè", "Gbèdjromèdé"],
    "Cotonou 2": ["Akpakpa Centre", "Cadjèhoun", "Mènontin", "Saint-Michel", "Védoko"],
    "Cotonou 3": ["Ahome", "Gbégamey", "Houénoussou", "Sikècodji", "Zogbo"],
    "Cotonou 4": ["Aïnan", "Dantokpa", "Missebo", "Saint-Jean", "Wansiru"],
    "Cotonou 5": ["Aïzon", "Djègan", "Gbéto", "Tokpa", "Zongo"],
    "Cotonou 6": ["Akpabo", "Dodoma", "Kpankpan", "Sèkandji", "Yénawa"],
    "Cotonou 7": ["Agla", "Ahouansori", "Fifadji", "Houéyiho", "Sègbeya"],
    "Cotonou 8": ["Ahome", "Djègan", "Gbégamey", "Mènontin", "Zogbo"],
    "Cotonou 9": ["Akassato", "Godomey", "Sègbeya", "Tokpa", "Zongo"],
    "Cotonou 10": ["Agbato", "Djègbadji", "Fidjrossè", "Sèdjè", "Wansiru"],
    "Cotonou 11": ["Ahome", "Gbégamey", "Houénoussou", "Sikècodji", "Zogbo"],
    "Cotonou 12": ["Aïnan", "Dantokpa", "Missebo", "Saint-Jean", "Wansiru"],
    "Cotonou 13": ["Aïzon", "Djègan", "Gbéto", "Tokpa", "Zongo"],
    
    // Porto-Novo
    "Porto-Novo": ["Adjohoun", "Aguégués", "Akpro-Missérété", "Avrankou", "Bonou", "Dangbo", "Sèmè-Kpodji"],
    
    // Parakou
    "Parakou": ["Djougou", "Bembèrèkè", "Kalalé", "N'Dali", "Nikki", "Pèrèrè", "Sinendé", "Tchaourou"],
    
    // Abomey
    "Abomey": ["Agbangnizoun", "Bohicon", "Covè", "Djidja", "Ouinhi", "Za-Kpota", "Zangnanado", "Zogbodomey"],
    
    // Lokossa
    "Lokossa": ["Athiémé", "Bopa", "Comè", "Grand-Popo", "Houéogbé"],
    
    // Natitingou
    "Natitingou": ["Boukoumbé", "Copargo", "Kérou", "Kouandé", "Pehunko", "Tanguiéta", "Toucountouna"],
    
    // Kandi
    "Kandi": ["Banikoara", "Gogounou", "Karimama", "Malanville", "Ségbana"],
    
    // Djougou
    "Djougou": ["Bassila", "Copargo", "Ouaké", "Pehunco"],
    
    // Ouidah
    "Ouidah": ["Abomey-Calavi", "Allada", "Kpomassè", "Sô-Ava", "Toffo", "Tori-Bossito", "Zè"],
    
    // Savè
    "Savè": ["Bantè", "Dassa-Zoumè", "Glazoué", "Ouessè", "Savalou"],
    
    // Autres villes principales
    "Abomey-Calavi": ["Abomey-Calavi", "Akassato", "Godomey"],
    "Allada": ["Allada", "Agbanou", "Ahlon-Cocohoué"],
    "Bohicon": ["Bohicon", "Bohicon", "Bohicon"],
    "Dassa-Zoumè": ["Dassa-Zoumè", "Dassa I", "Dassa II"],
    "Grand-Popo": ["Grand-Popo", "Grand-Popo", "Grand-Popo"],
    "Kétou": ["Kétou", "Kétou", "Kétou"],
    "Lokossa": ["Lokossa", "Lokossa", "Lokossa"],
    "Malanville": ["Malanville", "Garou", "Guénè"],
    "Natitingou": ["Natitingou", "Kota", "Kouaba"],
    "Ouidah": ["Ouidah", "Avlékété", "Djégbadji"],
    "Parakou": ["Parakou", "Parakou", "Parakou"],
    "Pobè": ["Pobè", "Pobè", "Pobè"],
    "Porto-Novo": ["Porto-Novo", "Porto-Novo", "Porto-Novo"],
    "Sakété": ["Sakété", "Sakété", "Sakété"],
    "Savè": ["Savè", "Adido", "Boni"],
  };

  @override
  void initState() {
    super.initState();
    _loadDepartements();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {bool isRequired = false}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      suffixIcon: isRequired
          ? const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _loadDepartements() async {
    setState(() => _isLoadingDepartements = true);
    try {
      final baseUrl = getApiBaseUrl();
      final res = await Dio().get('$baseUrl/geo/benin/departements');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data;
        setState(() {
          _departementsBenin
            ..clear()
            ..addAll(data.cast<Map<String, dynamic>>());
        });
      }
    } catch (e) {
      developer.log('[GEO] Erreur chargement départements: $e');
      // En cas d'erreur, charger les données statiques
      _loadStaticDepartements();
    } finally {
      if (mounted) setState(() => _isLoadingDepartements = false);
    }
  }

  void _loadStaticDepartements() {
    final staticData = [
      {"nom": "Alibori", "code": "AL", "chef_lieu": "Kandi"},
      {"nom": "Atacora", "code": "AK", "chef_lieu": "Natitingou"},
      {"nom": "Atlantique", "code": "AQ", "chef_lieu": "Ouidah"},
      {"nom": "Borgou", "code": "BO", "chef_lieu": "Parakou"},
      {"nom": "Collines", "code": "CO", "chef_lieu": "Savalou"},
      {"nom": "Couffo", "code": "CU", "chef_lieu": "Djakotomey"},
      {"nom": "Donga", "code": "DO", "chef_lieu": "Djougou"},
      {"nom": "Littoral", "code": "LI", "chef_lieu": "Cotonou"},
      {"nom": "Mono", "code": "MO", "chef_lieu": "Lokossa"},
      {"nom": "Ouémé", "code": "OU", "chef_lieu": "Porto-Novo"},
      {"nom": "Plateau", "code": "PL", "chef_lieu": "Pobè"},
      {"nom": "Zou", "code": "ZO", "chef_lieu": "Abomey"},
    ];
    
    if (mounted) {
      setState(() {
        _departementsBenin
          ..clear()
          ..addAll(staticData);
      });
    }
  }

  Future<void> _loadCommunes(String departement) async {
    setState(() => _isLoadingCommunes = true);
    try {
      final baseUrl = getApiBaseUrl();
      final res = await Dio().get('$baseUrl/geo/benin/departements/$departement/communes');
      if (res.statusCode == 200) {
        final List<dynamic> data = res.data;
        setState(() {
          _communesParDepartement[departement] = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      developer.log('[GEO] Erreur chargement communes: $e');
      // Charger les données statiques en cas d'erreur
      _loadStaticCommunes(departement);
    } finally {
      if (mounted) setState(() => _isLoadingCommunes = false);
    }
  }

  void _loadStaticCommunes(String departement) {
    final Map<String, List<Map<String, dynamic>>> staticCommunes = {
      "Alibori": [
        {"nom": "Banikoara", "arrondissements": ["Banikoara", "Founougo", "Gomparou"]},
        {"nom": "Gogounou", "arrondissements": ["Gogounou", "Bagou", "Bela"]},
        {"nom": "Kandi", "arrondissements": ["Kandi", "Angaradébou", "Bensékou"]},
        {"nom": "Karimama", "arrondissements": ["Karimama", "Birni-Lafia", "Bokoukou"]},
        {"nom": "Malanville", "arrondissements": ["Malanville", "Garou", "Guénè"]},
        {"nom": "Ségbana", "arrondissements": ["Ségbana", "Candé", "Liboussou"]},
      ],
      "Atacora": [
        {"nom": "Boukoumbé", "arrondissements": ["Boukoumbé", "Bella", "Dipoli"]},
        {"nom": "Copargo", "arrondissements": ["Copargo", "Agbanto", "Kokorou"]},
        {"nom": "Kérou", "arrondissements": ["Kérou", "Brignamaro", "Kao"]},
        {"nom": "Kouandé", "arrondissements": ["Kouandé", "Birni", "Chabri"]},
        {"nom": "Natitingou", "arrondissements": ["Natitingou", "Kota", "Kouaba"]},
        {"nom": "Pehunko", "arrondissements": ["Pehunko", "Béhanzin", "Béti"]},
        {"nom": "Tanguiéta", "arrondissements": ["Tanguiéta", "Cotonou", "Koussoucoingou"]},
        {"nom": "Toucountouna", "arrondissements": ["Toucountouna", "Kouarfa", "Tampégré"]},
      ],
      "Atlantique": [
        {"nom": "Abomey-Calavi", "arrondissements": ["Abomey-Calavi", "Akassato", "Godomey"]},
        {"nom": "Allada", "arrondissements": ["Allada", "Agbanou", "Ahlon-Cocohoué"]},
        {"nom": "Kpomassè", "arrondissements": ["Kpomassè", "Aganmalomè", "Agbanto"]},
        {"nom": "Ouidah", "arrondissements": ["Ouidah", "Avlékété", "Djégbadji"]},
        {"nom": "Sô-Ava", "arrondissements": ["Sô-Ava", "Aguégués", "Dékanmey"]},
        {"nom": "Toffo", "arrondissements": ["Toffo", "Adjohoun", "Aguégués"]},
        {"nom": "Tori-Bossito", "arrondissements": ["Tori-Bossito", "Avamé", "Azohouè-Aliho"]},
        {"nom": "Zè", "arrondissements": ["Zè", "Adjan", "Djigbé"]},
      ],
      "Borgou": [
        {"nom": "Bembèrèkè", "arrondissements": ["Bembèrèkè", "Bembèrèkè", "Bembèrèkè"]},
        {"nom": "Kalalé", "arrondissements": ["Kalalé", "Basso", "Basso"]},
        {"nom": "N'Dali", "arrondissements": ["N'Dali", "Basso", "Basso"]},
        {"nom": "Nikki", "arrondissements": ["Nikki", "Basso", "Basso"]},
        {"nom": "Parakou", "arrondissements": ["Parakou", "Basso", "Basso"]},
        {"nom": "Pèrèrè", "arrondissements": ["Pèrèrè", "Basso", "Basso"]},
        {"nom": "Sinendé", "arrondissements": ["Sinendé", "Basso", "Basso"]},
        {"nom": "Tchaourou", "arrondissements": ["Tchaourou", "Basso", "Basso"]},
      ],
      "Collines": [
        {"nom": "Bantè", "arrondissements": ["Bantè", "Agoua", "Akpassi"]},
        {"nom": "Dassa-Zoumè", "arrondissements": ["Dassa-Zoumè", "Dassa I", "Dassa II"]},
        {"nom": "Glazoué", "arrondissements": ["Glazoué", "Aklankpa", "Assao"]},
        {"nom": "Ouessè", "arrondissements": ["Ouessè", "Ahouansouè", "Djamè"]},
        {"nom": "Savalou", "arrondissements": ["Savalou", "Aglahou", "Djalakouè"]},
        {"nom": "Savè", "arrondissements": ["Savè", "Adido", "Boni"]},
      ],
      "Couffo": [
        {"nom": "Aplahoué", "arrondissements": ["Aplahoué", "Aplahoué", "Aplahoué"]},
        {"nom": "Djakotomey", "arrondissements": ["Djakotomey", "Djakotomey", "Djakotomey"]},
        {"nom": "Dogbo", "arrondissements": ["Dogbo", "Dogbo", "Dogbo"]},
        {"nom": "Klouékanmè", "arrondissements": ["Klouékanmè", "Klouékanmè", "Klouékanmè"]},
        {"nom": "Lalo", "arrondissements": ["Lalo", "Lalo", "Lalo"]},
        {"nom": "Toviklin", "arrondissements": ["Toviklin", "Toviklin", "Toviklin"]},
      ],
      "Donga": [
        {"nom": "Bassila", "arrondissements": ["Bassila", "Bassila", "Bassila"]},
        {"nom": "Copargo", "arrondissements": ["Copargo", "Copargo", "Copargo"]},
        {"nom": "Djougou", "arrondissements": ["Djougou", "Djougou", "Djougou"]},
        {"nom": "Ouaké", "arrondissements": ["Ouaké", "Ouaké", "Ouaké"]},
        {"nom": "Pehunco", "arrondissements": ["Pehunco", "Pehunco", "Pehunco"]},
      ],
      "Littoral": [
        {"nom": "Cotonou", "arrondissements": ["Cotonou 1", "Cotonou 2", "Cotonou 3", "Cotonou 4", "Cotonou 5", "Cotonou 6", "Cotonou 7", "Cotonou 8", "Cotonou 9", "Cotonou 10", "Cotonou 11", "Cotonou 12", "Cotonou 13"]},
      ],
      "Mono": [
        {"nom": "Athiémé", "arrondissements": ["Athiémé", "Athiémé", "Athiémé"]},
        {"nom": "Bopa", "arrondissements": ["Bopa", "Bopa", "Bopa"]},
        {"nom": "Comè", "arrondissements": ["Comè", "Comè", "Comè"]},
        {"nom": "Grand-Popo", "arrondissements": ["Grand-Popo", "Grand-Popo", "Grand-Popo"]},
        {"nom": "Houéogbé", "arrondissements": ["Houéogbé", "Houéogbé", "Houéogbé"]},
        {"nom": "Lokossa", "arrondissements": ["Lokossa", "Lokossa", "Lokossa"]},
      ],
      "Ouémé": [
        {"nom": "Adjarra", "arrondissements": ["Adjarra", "Adjarra", "Adjarra"]},
        {"nom": "Adjohoun", "arrondissements": ["Adjohoun", "Adjohoun", "Adjohoun"]},
        {"nom": "Aguégués", "arrondissements": ["Aguégués", "Aguégués", "Aguégués"]},
        {"nom": "Akpro-Missérété", "arrondissements": ["Akpro-Missérété", "Akpro-Missérété", "Akpro-Missérété"]},
        {"nom": "Avrankou", "arrondissements": ["Avrankou", "Avrankou", "Avrankou"]},
        {"nom": "Bonou", "arrondissements": ["Bonou", "Bonou", "Bonou"]},
        {"nom": "Dangbo", "arrondissements": ["Dangbo", "Dangbo", "Dangbo"]},
        {"nom": "Porto-Novo", "arrondissements": ["Porto-Novo", "Porto-Novo", "Porto-Novo"]},
        {"nom": "Sèmè-Kpodji", "arrondissements": ["Sèmè-Kpodji", "Sèmè-Kpodji", "Sèmè-Kpodji"]},
      ],
      "Plateau": [
        {"nom": "Adja-Ouèrè", "arrondissements": ["Adja-Ouèrè", "Adja-Ouèrè", "Adja-Ouèrè"]},
        {"nom": "Ifangni", "arrondissements": ["Ifangni", "Ifangni", "Ifangni"]},
        {"nom": "Kétou", "arrondissements": ["Kétou", "Kétou", "Kétou"]},
        {"nom": "Pobè", "arrondissements": ["Pobè", "Pobè", "Pobè"]},
        {"nom": "Sakété", "arrondissements": ["Sakété", "Sakété", "Sakété"]},
      ],
      "Zou": [
        {"nom": "Abomey", "arrondissements": ["Abomey", "Abomey", "Abomey"]},
        {"nom": "Agbangnizoun", "arrondissements": ["Agbangnizoun", "Agbangnizoun", "Agbangnizoun"]},
        {"nom": "Bohicon", "arrondissements": ["Bohicon", "Bohicon", "Bohicon"]},
        {"nom": "Covè", "arrondissements": ["Covè", "Covè", "Covè"]},
        {"nom": "Djidja", "arrondissements": ["Djidja", "Djidja", "Djidja"]},
        {"nom": "Ouinhi", "arrondissements": ["Ouinhi", "Ouinhi", "Ouinhi"]},
        {"nom": "Za-Kpota", "arrondissements": ["Za-Kpota", "Za-Kpota", "Za-Kpota"]},
        {"nom": "Zangnanado", "arrondissements": ["Zangnanado", "Zangnanado", "Zangnanado"]},
        {"nom": "Zogbodomey", "arrondissements": ["Zogbodomey", "Zogbodomey", "Zogbodomey"]},
      ],
    };

    if (mounted) {
      setState(() {
        _communesParDepartement[departement] = staticCommunes[departement] ?? [];
      });
    }
  }

  Future<void> _loadVilles(String commune) async {
    setState(() => _isLoadingVilles = true);
    try {
      // Pour l'instant, charger les arrondissements comme "villes"
      if (_selectedDepartement != null) {
        final communes = _communesParDepartement[_selectedDepartement!] ?? [];
        final communeData = communes.firstWhere(
          (c) => c['nom']?.toString() == commune,
          orElse: () => {'nom': commune, 'arrondissements': <String>[]},
        );
        
        final arrondissements = List<String>.from(communeData['arrondissements'] ?? []);
        
        if (mounted) {
          setState(() {
            _villesParCommune[commune] = arrondissements;
          });
        }
      }
    } catch (e) {
      developer.log('[GEO] Erreur chargement villes: $e');
    } finally {
      if (mounted) setState(() => _isLoadingVilles = false);
    }
  }

  Future<void> _loadQuartiers(String ville) async {
    setState(() => _isLoadingQuartiers = true);
    try {
      // Utiliser les vrais quartiers si disponibles, sinon générer des quartiers génériques
      List<String> quartiers = _quartiersReels[ville] ?? [];
      
      // Si pas de quartiers prédéfinis, générer des quartiers basés sur la ville
      if (quartiers.isEmpty) {
        quartiers = [
          'Centre-ville',
          'Marché central',
          'Zone administrative',
          'Résidentiel Nord',
          'Résidentiel Sud',
          'Zone commerciale',
          'Quartier artisanal',
          'Zone industrielle',
        ];
      }
      
      if (mounted) {
        setState(() {
          _quartiersParVille[ville] = quartiers;
        });
      }
    } catch (e) {
      developer.log('[GEO] Erreur chargement quartiers: $e');
    } finally {
      if (mounted) setState(() => _isLoadingQuartiers = false);
    }
  }

  Future<void> _calculateDeliveryFeeFromLocation() async {
    if (_deliveryLatitude != null && _deliveryLongitude != null) {
      setState(() => _isCalculatingDeliveryFee = true);
      try {
        final cart = Provider.of<CartService>(context, listen: false);
        
        // Récupérer tous les fournisseurs uniques dans le panier
        final Map<String, Map<String, dynamic>> suppliers = {};
        for (final item in cart.items) {
          if (item.supplierId != null && 
              item.supplierLatitude != null && 
              item.supplierLongitude != null) {
            suppliers[item.supplierId!] = {
              'name': item.supplierName ?? 'Fournisseur',
              'latitude': item.supplierLatitude!,
              'longitude': item.supplierLongitude!,
            };
          }
        }
        
        if (suppliers.isEmpty) {
          // Utiliser Cotonou par défaut si aucun fournisseur avec coordonnées
          suppliers['default'] = {
            'name': 'Cotonou',
            'latitude': 6.3654,
            'longitude': 2.4183,
          };
        }
        
        // Calculer les frais pour chaque fournisseur et prendre le maximum
        double maxDeliveryFee = 0;
        String selectedSupplier = '';
        Map<String, dynamic>? zoneInfo;
        
        for (final entry in suppliers.entries) {
          final supplier = entry.value;
          final response = await Dio().post(
            '${dotenv.env['API_BASE_URL']}/delivery-zones/calculate-fee',
            data: {
              'supplier_lat': supplier['latitude'],
              'supplier_lng': supplier['longitude'],
              'delivery_lat': _deliveryLatitude,
              'delivery_lng': _deliveryLongitude,
            },
          );
          
          if (response.statusCode == 200) {
            final fee = response.data['delivery_fee']?.toDouble() ?? 0.0;
            if (fee > maxDeliveryFee) {
              maxDeliveryFee = fee;
              selectedSupplier = supplier['name'];
              zoneInfo = response.data['zoneInfo'];
            }
          }
        }
        
        setState(() {
          _deliveryFee = maxDeliveryFee;
        });
        
        final zoneName = zoneInfo?['name'] ?? 'Zone standard';
        developer.log('Frais de livraison calculés: $_deliveryFee F (fournisseur: $selectedSupplier, zone: $zoneName)');
      } catch (e) {
        developer.log('Error calculating delivery fee: $e');
      } finally {
        if (mounted) setState(() => _isCalculatingDeliveryFee = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résumé'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          final double subtotal = cart.subtotal;
          final double total = (subtotal + _deliveryFee).clamp(
            0,
            double.infinity,
          );

          return Column(
            children: [
              // Contenu défilant
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ...cart.items.map(
                        (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${i.quantity} x ${i.title}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('${i.totalPrice.toStringAsFixed(0)} F'),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 24),

                      // Adresse de livraison dynamique
                      const Text(
                        'Adresse de livraison',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartement,
                        decoration: _inputDecoration(
                          _isLoadingDepartements 
                              ? 'Chargement des départements...' 
                              : 'Sélectionner le département',
                          isRequired: true
                        ),
                        items: _departementsBenin
                            .map<DropdownMenuItem<String>>(
                              (d) {
                                final nom = d['nom']?.toString() ?? '';
                                return DropdownMenuItem<String>(
                                  value: nom,
                                  child: Text(nom),
                                );
                              },
                            )
                            .toList(),
                        onChanged: _isLoadingDepartements ? null : (value) async {
                          setState(() {
                            _selectedDepartement = value;
                            _selectedCommune = null;
                            _selectedVille = null;
                            _selectedQuartier = null;
                          });
                          if (value != null) {
                            await _loadCommunes(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCommune,
                        decoration: _inputDecoration(
                          _isLoadingCommunes 
                              ? 'Chargement des communes...' 
                              : 'Sélectionner la commune',
                          isRequired: true
                        ),
                        items: (_selectedDepartement != null
                                ? _communesParDepartement[_selectedDepartement!] ?? []
                                : [])
                            .map<DropdownMenuItem<String>>(
                              (c) {
                                final nom = c['nom']?.toString() ?? '';
                                return DropdownMenuItem<String>(
                                  value: nom,
                                  child: Text(nom),
                                );
                              },
                            )
                            .toList(),
                        onChanged: _isLoadingCommunes ? null : (value) async {
                          setState(() {
                            _selectedCommune = value;
                            _selectedVille = null;
                            _selectedQuartier = null;
                          });
                          if (value != null) {
                            await _loadVilles(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedVille,
                        decoration: _inputDecoration(
                          _isLoadingVilles 
                              ? 'Chargement des villes...' 
                              : 'Sélectionner la ville',
                          isRequired: true
                        ),
                        items: (_selectedCommune != null
                                ? _villesParCommune[_selectedCommune!] ?? []
                                : [])
                            .map<DropdownMenuItem<String>>(
                              (v) => DropdownMenuItem<String>(
                                value: v,
                                child: Text(v),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoadingVilles ? null : (value) async {
                          setState(() {
                            _selectedVille = value;
                            _selectedQuartier = null;
                          });
                          if (value != null) {
                            await _loadQuartiers(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedQuartier,
                        decoration: _inputDecoration(
                          _isLoadingQuartiers 
                              ? 'Chargement des quartiers...' 
                              : 'Sélectionner le quartier',
                          isRequired: true
                        ),
                        items: (_selectedVille != null
                                ? _quartiersParVille[_selectedVille!] ?? []
                                : [])
                            .map<DropdownMenuItem<String>>(
                              (q) => DropdownMenuItem<String>(
                                value: q,
                                child: Text(q),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoadingQuartiers ? null : (value) {
                          setState(() {
                            _selectedQuartier = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: _inputDecoration('Adresse détaillée (Ex: Maison verte, près de ...)', isRequired: true),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        maxLength: 500,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Ajouter une note de livraison',
                          border: OutlineInputBorder(),
                          counterText: '0/500',
                        ),
                      ),

                      const SizedBox(height: 8),
                      // Total de la commande
                      const Text(
                        'Total de la commande',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _rowKV('Sous-total', '${subtotal.toStringAsFixed(0)} F'),
                      const SizedBox(height: 6),
                      _rowKV(
                        'Frais de livraison',
                        _isCalculatingDeliveryFee 
                            ? 'Calcul en cours...'
                            : '${_deliveryFee.toStringAsFixed(0)} F',
                        trailing: _isCalculatingDeliveryFee 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                      ),
                      const Divider(height: 24),
                      _rowKV('Total', '${total.toStringAsFixed(0)} F', isBold: true),

                      const SizedBox(height: 16),
                      // Note sur le paiement
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade50, Colors.amber.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Information sur le paiement',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Le paiement s\'effectuera directement sur l\'application lorsque le livreur arrivera à votre adresse. Vous pourrez payer par mobile money ou carte bancaire de manière sécurisée.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  color: Colors.green.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Paiement 100% sécurisé',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Espacement réduit pour le bouton fixe
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // Bouton de validation fixe en bas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cart.items.isEmpty || _isProcessing
                        ? null
                        : () async {
                            // Confirmer la commande
                            final confirmed = await _confirmOrder(total);
                            if (confirmed && mounted) {
                              await _processOrder(total, cart);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Commander • ${total.toStringAsFixed(0)} F'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _rowKV(String k, String v, {bool isBold = false, Widget? trailing}) {
    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(k, style: const TextStyle(color: Colors.black54))),
        if (trailing != null) ...[trailing, const SizedBox(width: 8)],
        Text(v, style: textStyle),
      ],
    );
  }

  Future<void> _selectLocationFromList() async {
    final List<String> commonAddresses = [
      'Cotonou, Bénin',
      'Porto-Novo, Bénin',
      'Lomé, Togo',
      'Accra, Ghana',
      'Lagos, Nigeria',
      'Abidjan, Côte d\'Ivoire',
      'Dakar, Sénégal',
      'Bamako, Mali',
      'Ouagadougou, Burkina Faso',
      'Niamey, Niger',
    ];

    final selectedAddress = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une adresse'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: commonAddresses.length,
            itemBuilder: (context, index) {
              final address = commonAddresses[index];
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(address),
                onTap: () => Navigator.pop(context, address),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (selectedAddress != null && mounted) {
      setState(() {
        _addressController.text = selectedAddress;
      });
    }
  }

  Future<bool> _confirmOrder(double total) async {
    developer.log('=== DÉBUT VALIDATION COMMANDE ===');
    developer.log('Total: $total');
    
    // Vérifier si tous les champs obligatoires sont remplis
    final departement = _selectedDepartement;
    final commune = _selectedCommune;
    final ville = _selectedVille;
    final quartier = _selectedQuartier;
    final address = _addressController.text.trim();
    
    developer.log('Département: $departement');
    developer.log('Commune: $commune');
    developer.log('Ville: $ville');
    developer.log('Quartier: $quartier');
    developer.log('Adresse: $address');
    
    if (departement == null || 
        commune == null || 
        ville == null || 
        quartier == null ||
        address.isEmpty) {
      
      developer.log('❌ VALIDATION ÉCHOUÉE - Champs manquants');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires (*)'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }

    developer.log('✅ VALIDATION RÉUSSIE - Tous les champs sont remplis');

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Confirmer votre commande',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total à payer: ${total.toStringAsFixed(0)} F',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Adresse de livraison:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_addressController.text.trim()}, ${_selectedQuartier ?? ''}, ${_selectedVille ?? ''}, ${_selectedCommune ?? ''}, ${_selectedDepartement ?? ''}',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirmer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  Future<void> _processOrder(double total, CartService cart) async {
    developer.log('=== DÉBUT PROCESSUS COMMANDE ===');
    developer.log('Total: $total');
    developer.log('Nombre d\'articles: ${cart.items.length}');
    
    setState(() => _isProcessing = true);

    try {
      developer.log('ÉTAPE 1: Sauvegarde commande en base de données...');
      
      // Le paiement est toujours en ligne mais se fait après réception du colis
      // Donc paymentMethod = 'online' et status = 'pending'
      const paymentMethodStr = 'online';
      developer.log('Méthode de paiement: $paymentMethodStr (paiement après réception)');
      
      // Sauvegarder la commande en base de données
      await _saveOrderToDatabase(total, cart, paymentMethodStr);
      developer.log('ÉTAPE 1: Commande sauvegardée avec succès');
      
      developer.log('ÉTAPE 2: Vidage du panier...');
      // Vider complètement le panier et notifier les listeners
      cart.clear();
      developer.log('ÉTAPE 2: Panier vidé - Articles restants: ${cart.items.length}');
      
      developer.log('ÉTAPE 3: Mise à jour CounterProvider...');
      // Forcer la mise à jour du CounterProvider pour le badge du panier
      if (mounted) {
        try {
          final counterProvider = Provider.of<CounterProvider>(context, listen: false);
          counterProvider.clearCart();
          developer.log('ÉTAPE 3: CounterProvider mis à jour');
        } catch (e) {
          developer.log('ERREUR CounterProvider: $e');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande confirmée avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Attendre un peu avant de rediriger
        await Future.delayed(const Duration(milliseconds: 1500));
        
        developer.log('ÉTAPE 4: Redirection vers page commandes...');
        // Rediriger vers la page des commandes
        Navigator.pushReplacementNamed(context, '/orders');
        developer.log('=== FIN PROCESSUS COMMANDE - SUCCÈS ===');
      }
    } catch (e) {
      developer.log('=== ERREUR PROCESSUS COMMANDE ===');
      developer.log('Erreur type: ${e.runtimeType}');
      developer.log('Erreur message: $e');
      developer.log('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _processOnlinePayment(double total) async {
    setState(() => _isProcessing = true);

    try {
      final token = dotenv.env['FP_TOKEN_FEEXPAY'] ?? '';
      final idUser = dotenv.env['ID_USER_FEEXPAY'] ?? '';

      if (token.isEmpty || idUser.isEmpty) {
        throw Exception('Configuration FeexPay manquante');
      }

      // Redirection directe vers FeexPay
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChoicePage(
            token: token,
            id: idUser,
            amount: total.toStringAsFixed(0),
            redirecturl: '/cart-payment-success',
            errorredirecturl: '/cart-payment-error',
            trans_key: _transKey,
          ),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de paiement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveOrderToDatabase(
    double total,
    CartService cart,
    String paymentMethod,
  ) async {
    developer.log('=== DÉBUT SAUVEGARDE COMMANDE ===');
    developer.log('Total: $total');
    developer.log('Méthode paiement: $paymentMethod');
    developer.log('Nombre d\'articles: ${cart.items.length}');
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      developer.log('ERREUR: Utilisateur non connecté');
      throw Exception('Utilisateur non connecté');
    }
    
    developer.log('Utilisateur connecté: ${user.uid}');

    try {
      final token = await user.getIdToken();
      final baseUrl = getApiBaseUrl();
      developer.log('Token obtenu, Base URL: $baseUrl');
      
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Préparer les données de la commande
      developer.log('Préparation des données commande...');
      
      final itemsData = cart.items.map((item) {
        developer.log('Article: ${item.title} - ${item.imageUrl}');
        return {
          'articleId': item.articleId,
          'title': item.title,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'totalPrice': item.totalPrice,
          'imageUrl': item.imageUrl, // Ajouter l'image explicitement
        };
      }).toList();

      // Récupérer les informations du fournisseur depuis le premier article du panier
      Map<String, dynamic>? lieuDepart;
      if (cart.items.isNotEmpty) {
        final firstItem = cart.items.first;
        if (firstItem.supplierId != null && 
            firstItem.supplierLatitude != null && 
            firstItem.supplierLongitude != null) {
          lieuDepart = {
            'nom': firstItem.supplierName ?? 'Fournisseur',
            'adresse': firstItem.supplierName ?? 'Adresse fournisseur',
            'latitude': firstItem.supplierLatitude,
            'longitude': firstItem.supplierLongitude,
          };
        }
      }

      // Si pas de fournisseur trouvé, utiliser Cotonou par défaut
      lieuDepart ??= {
        'nom': 'Cotonou',
        'adresse': 'Cotonou, Bénin',
        'latitude': 6.3654,
        'longitude': 2.4183,
      };

      final orderData = {
        'items': itemsData,
        'subtotal': cart.subtotal,
        'deliveryFee': _deliveryFee,
        'total': total,
        'paymentMethod': paymentMethod,
        'deliveryAddress': '${_selectedDepartement ?? ''}, ${_selectedCommune ?? ''}, ${_selectedVille ?? ''}, ${_selectedQuartier ?? ''}, ${_addressController.text.trim()}',
        'deliveryNote': _noteController.text.trim(),
        'status': 'pending', // Toujours 'pending' car le paiement se fait après réception
        'isDeliveryRequired': true,
        'deliveryInfo': {
          'lieuDepart': lieuDepart,
          'lieuDestination': {
            'adresse': '${_selectedDepartement ?? ''}, ${_selectedCommune ?? ''}, ${_selectedVille ?? ''}, ${_selectedQuartier ?? ''}, ${_addressController.text.trim()}',
            'latitude': _deliveryLatitude,
            'longitude': _deliveryLongitude,
          }
        },
        'conditionsAffichee': true,
      };

      developer.log('Données commande préparées - ${orderData.keys.length} champs');
      developer.log('URL de la requête: $baseUrl/orders');
      developer.log('Adresse livraison: ${orderData['deliveryAddress']}');
      developer.log('Coordonnées: (${_deliveryLatitude}, ${_deliveryLongitude})');
      
      developer.log('ÉTAPE: Envoi requête POST...');
      final response = await dio.post('/orders', data: orderData);
      
      developer.log('Statut réponse: ${response.statusCode}');
      developer.log('Données réponse: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('✅ COMMANDE SAUVEGARDÉE AVEC SUCCÈS');
      } else {
        developer.log('❌ ERREUR SAUVEGARDE - Code: ${response.statusCode}');
        throw Exception('Erreur lors de la sauvegarde: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('=== ERREUR SAUVEGARDE COMMANDE ===');
      developer.log('Type erreur: ${e.runtimeType}');
      developer.log('Message erreur: $e');
      
      if (e is DioException) {
        developer.log('ERREUR DIO: ${e.message}');
        developer.log('STATUT: ${e.response?.statusCode}');
        developer.log('DONNÉES: ${e.response?.data}');
        developer.log('HEADERS: ${e.response?.headers}');
      }
      
      throw Exception('Erreur lors de la sauvegarde de la commande: ${e.toString()}');
    }
  }

  Future<void> _showSuccessModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Commande confirmée !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Votre commande a été enregistrée avec succès.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_shipping,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Livraison prévue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entre 3 et 7 jours ouvrables',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Vous recevrez une notification',
                        style: TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Parfait !',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<double> _calculateDeliveryFee(double lat, double lng) async {
    try {
      // Coordonnées par défaut (Cotonou) pour cette fonction de compatibilité
      final supplierLat = 6.3654;
      final supplierLng = 2.4183;
      
      final response = await Dio().post(
        '${getApiBaseUrl()}/delivery-zones/calculate-fee',
        data: {
          'supplier_lat': supplierLat,
          'supplier_lng': supplierLng,
          'delivery_lat': lat,
          'delivery_lng': lng,
        },
      );
      if (response.statusCode == 200) {
        return response.data['delivery_fee'] ?? 0.0;
      } else {
        throw Exception('Failed to calculate delivery fee');
      }
    } catch (e) {
      debugPrint('Error calculating delivery fee: $e');
      return 0.0;
    }
  }
}
