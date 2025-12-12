// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'cars_info.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';
import 'create_sell.dart';
import 'movie.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';

class VoituresPage extends StatefulWidget {
  const VoituresPage({super.key});

  @override
  State<VoituresPage> createState() => _VoituresPageState();
}

class _VoituresPageState extends State<VoituresPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> voitures = [];
  bool isLoading = true;
  String? error;
  List<bool> _isVisible = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  // Filtres
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedLocation;
  double? _budgetMin;
  double? _budgetMax;

  // TabController pour les filtres
  late TabController _tabController;
  late int _marqueTabIndex;
  late int _modeleTabIndex;
  late int _localisationTabIndex;
  late int _budgetTabIndex;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    // Initialisation des indices des onglets selon le rôle
    final isVendeur = _userService.currentRole == UserRole.vendeur;
    if (isVendeur) {
      // Vendeur: pas de filtres Localisation/Budget
      _marqueTabIndex = 0;
      _modeleTabIndex = 1;
      _tabController = TabController(length: 2, vsync: this);
    } else {
      // Autres rôles: tous les filtres
      _marqueTabIndex = 0;
      _modeleTabIndex = 1;
      _localisationTabIndex = 2;
      _budgetTabIndex = 3;
      _tabController = TabController(length: 4, vsync: this);
    }

    _tabController.addListener(() {
      setState(() {});
    });

    fetchVoitures();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double _computeCardAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 0.58;
    if (screenWidth < 420) return 0.59;
    if (screenWidth < 520) return 0.7;
    return 0.78;
  }

  void _reloadAll() {
    // Réinitialiser la recherche
    _searchController.clear();
    _searchText = '';

    // Réinitialiser les filtres
    _selectedBrand = null;
    _selectedModel = null;
    _selectedLocation = null;
    _budgetMin = null;
    _budgetMax = null;

    // Recharger les données
    fetchVoitures();
    setState(() {});
  }

  Future<void> fetchVoitures() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final userService = UserService();
      final role = userService.currentRole;
      final userId = user?.uid;
      String url = getBaseUrl() + '/articles?type=voiture';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          voitures = data;
          _isVisible = List.generate(data.length, (index) => true);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Erreur lors du chargement des voitures';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur réseau';
        isLoading = false;
      });
    }
  }

  Future<void> _deleteVoiture(String articleId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Voulez-vous vraiment supprimer cette voiture ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _isVisible[index] = false;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final response = await http.delete(
        Uri.parse(getBaseUrl() + '/articles/$articleId'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voiture supprimée avec succès !')),
        );
        fetchVoitures();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau ou serveur.')),
      );
    }
  }

  // Appliquer les filtres
  List<dynamic> _applyFilters(List<dynamic> source) {
    return source.where((v) {
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        final marque = (v['marque'] ?? '').toString().toLowerCase();
        if (!marque.contains(_selectedBrand!.toLowerCase())) {
          return false;
        }
      }
      if (_selectedModel != null && _selectedModel!.isNotEmpty) {
        final modele = (v['modele'] ?? '').toString().toLowerCase();
        if (!modele.contains(_selectedModel!.toLowerCase())) {
          return false;
        }
      }
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        final loc = ((v['entreprise'] ?? '') + ' ' + (v['description'] ?? ''))
            .toLowerCase();
        if (!loc.contains(_selectedLocation!.toLowerCase()) &&
            !((v['titre'] ?? '')
                .toString()
                .toLowerCase()
                .contains(_selectedLocation!.toLowerCase()))) {
          return false;
        }
      }
      if (_budgetMin != null || _budgetMax != null) {
        final prixStr = (v['prix'] ?? '').toString();
        final price =
            double.tryParse(prixStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (_budgetMin != null && price < _budgetMin!) return false;
        if (_budgetMax != null && price > _budgetMax!) return false;
      }
      return true;
    }).toList();
  }

  Widget _buildCaracteristic(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.amber[700]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, int index, {bool isWide = false}) {
    bool isSelected = _tabController.index == index;
    const selectedColor = Color(0xFFF8BF13);
    const unselectedBorderColor = Color(0xFF000000);
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = index;
        });
      },
      child: Container(
        width: isWide ? 100 : 70,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? selectedColor : unselectedBorderColor,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMarqueSection() {
    final List<Map<String, String>> marques = [
      {"name": "Toyota", "image": "assets/images/Toyota.png"},
      {"name": "Nissan", "image": "assets/images/nissan.png"},
      {"name": "Ford", "image": "assets/images/ford.png"},
      {"name": "Hyundai", "image": "assets/images/hunydai.png"},
      {"name": "Honda", "image": "assets/images/honda.png"},
      {"name": "Kia", "image": "assets/images/kia.png"},
      {"name": "BMW", "image": "assets/images/bmw.png"},
      {"name": "Mercedes", "image": "assets/images/mercedes.png"},
      {"name": "Audi", "image": "assets/images/Audi.png"},
      {"name": "Volkswagen", "image": "assets/images/vw.png"},
      {"name": "Lexus", "image": "assets/images/lexus.png"},
      {"name": "Mazda", "image": "assets/images/mazda.webp"},
      {"name": "Chevrolet", "image": "assets/images/chevrolet.png"},
      {"name": "Jeep", "image": "assets/images/jeep.png"},
      {"name": "Peugeot", "image": "assets/images/peugeot.png"},
      {"name": "Renault", "image": "assets/images/renault.png"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 100 + 16,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 100,
          ),
          itemCount: marques.length,
          itemBuilder: (context, index) {
            final item = marques[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedBrand = item["name"];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedBrand == item["name"]
                      ? const Color(0xFFF8BF13)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedBrand == item["name"]
                        ? const Color(0xFFF8BF13)
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Image.asset(
                        item["image"] ?? '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) {
                          return CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade300,
                            child: Text(
                              (item["name"] ?? '??').substring(0, 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["name"] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedBrand == item["name"]
                            ? Colors.white
                            : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeleSection() {
    final List<String> modeles = [
      'Land Cruiser',
      'Patrol',
      'Altima',
      'RAV4',
      'Hilux',
      'Wrangler',
      'Civic',
      'Corolla',
      'Camry',
      'Accord',
      'Tucson',
      'Sportage',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 90 + 16,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 120,
          ),
          itemCount: modeles.length,
          itemBuilder: (context, index) {
            final name = modeles[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedModel = name;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedModel == name
                      ? const Color(0xFFF8BF13)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedModel == name
                        ? const Color(0xFFF8BF13)
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedModel == name ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocalisationSection() {
    final List<Map<String, dynamic>> zones = [
      {"name": "Bénin", "image": "assets/images/benin.png"},
      {"name": "Mali", "image": "assets/images/mali.png"},
      {"name": "Niger", "image": "assets/images/niger.png"},
      {"name": "Burkina-Faso", "image": "assets/images/burkina.png"},
      {"name": "Côte d'Ivoire", "image": "assets/images/ci.webp"},
      {"name": "Sénégal", "image": "assets/images/senegal.png"},
      {"name": "Togo", "image": "assets/images/togo.webp"},
      {"name": "Ghana", "image": "assets/images/ghana.png"},
      {"name": "Nigéria", "image": "assets/images/nigeria.png"},
      {"name": "Maroc", "image": "assets/images/maroc.png"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 106,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 120,
          ),
          itemCount: zones.length,
          itemBuilder: (context, index) {
            final item = zones[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLocation = item["name"];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedLocation == item["name"]
                      ? const Color(0xFFF8BF13)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedLocation == item["name"]
                        ? const Color(0xFFF8BF13)
                        : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 24,
                      child: Image.asset(item["image"], fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["name"],
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedLocation == item["name"]
                            ? Colors.white
                            : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF8BF13),
            foregroundColor: const Color(0xFF000000),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _openBudgetSheet,
          child: const Text('Filtrer par budget'),
        ),
      ),
    );
  }

  void _openBudgetSheet() {
    final List<double> prixList = voitures
        .map((v) => double.tryParse(
            (v['prix'] ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), '')))
        .whereType<double>()
        .toList()
      ..sort();

    final double minPrice = prixList.isNotEmpty ? prixList.first : 0;
    final double maxPrice = prixList.isNotEmpty ? prixList.last : 200000;
    double currentMin = _budgetMin ?? minPrice;
    double currentMax = _budgetMax ?? maxPrice;

    final minCtl = TextEditingController(text: currentMin.toStringAsFixed(0));
    final maxCtl = TextEditingController(text: currentMax.toStringAsFixed(0));

    int compterDansIntervalle(double a, double b) {
      return voitures.where((v) {
        final p = double.tryParse(
            (v['prix'] ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), ''));
        if (p == null) return false;
        return p >= a && p <= b;
      }).length;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final disponibles = compterDansIntervalle(currentMin, currentMax);
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Prix (FCFA)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Min.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) {
                            final v = double.tryParse(val) ?? currentMin;
                            setModalState(() {
                              currentMin = v.clamp(minPrice, currentMax);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxCtl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (val) {
                            final v = double.tryParse(val) ?? currentMax;
                            setModalState(() {
                              currentMax = v.clamp(currentMin, maxPrice);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('$disponibles véhicule(s) disponible(s)'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _budgetMin = null;
                              _budgetMax = null;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8BF13),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _budgetMin = currentMin;
                              _budgetMax = currentMax;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final isVendeur = userService.currentRole == UserRole.vendeur;

    final filteredVoitures = _applyFilters(voitures).where((v) {
      final titre = ((v['marque'] ?? '').toString() +
              ' ' +
              (v['modele']?.toString() ?? ''))
          .toLowerCase();
      final alt = (v['titre'] ?? '').toString().toLowerCase();
      if (_searchText.isEmpty) return true;
      return titre.contains(_searchText) || alt.contains(_searchText);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voitures en ligne'),
        backgroundColor: Colors.amber,
        actions: [
          if (isVendeur)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSellPage(),
                  ),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Column(
                  children: [
                    // Barre de recherche
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Rechercher une voiture (marque, modèle, titre)...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh,
                                color: Color(0xFF8C9199)),
                            onPressed: _reloadAll,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // Filtres TabBar
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.center,
                          indicator: const BoxDecoration(),
                          padding: EdgeInsets.zero,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          tabs: [
                            _buildTabButton("Marque", _marqueTabIndex),
                            _buildTabButton("Modèles", _modeleTabIndex),
                            if (!isVendeur)
                              _buildTabButton(
                                "Localisation",
                                _localisationTabIndex,
                                isWide: true,
                              ),
                            if (!isVendeur)
                              _buildTabButton("Budget", _budgetTabIndex),
                          ],
                        ),
                      ),
                    ),
                    // Sections de filtres
                    if (_tabController.index == _marqueTabIndex)
                      _buildMarqueSection(),
                    if (_tabController.index == _modeleTabIndex)
                      _buildModeleSection(),
                    if (!isVendeur &&
                        _tabController.index == _localisationTabIndex)
                      _buildLocalisationSection(),
                    if (!isVendeur && _tabController.index == _budgetTabIndex)
                      _buildBudgetSection(),
                    // Liste des voitures
                    Expanded(
                      child: filteredVoitures.isEmpty
                          ? Center(
                              child: Text(
                                isVendeur
                                    ? "Vous n'avez aucune voiture en ligne"
                                    : "Aucune voiture disponible pour le moment.",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13.0),
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio:
                                      _computeCardAspectRatio(context),
                                ),
                                itemCount: filteredVoitures.length,
                                itemBuilder: (context, index) {
                                  final voiture = filteredVoitures[index];
                                  return AnimatedOpacity(
                                    opacity: _isVisible.length > index &&
                                            _isVisible[index]
                                        ? 1.0
                                        : 0.0,
                                    duration: const Duration(milliseconds: 400),
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CarsInfo(
                                                  id: (voiture['_id'] ??
                                                          voiture['id'] ??
                                                          voiture[
                                                              'articleId'] ??
                                                          voiture['Id'] ??
                                                          voiture['article'])
                                                      ?.toString(),
                                                  titre: voiture['titre'] ?? '',
                                                  description:
                                                      voiture['description'] ??
                                                          '',
                                                  marque:
                                                      voiture['marque'] ?? '',
                                                  modele: voiture['modele']
                                                          ?.toString() ??
                                                      '',
                                                  annee: voiture['annee'] ?? '',
                                                  prix: voiture['prix']
                                                          ?.toString() ??
                                                      '',
                                                  condition:
                                                      voiture['condition'],
                                                  boiteVitesse:
                                                      voiture['boiteVitesse'],
                                                  carburant:
                                                      voiture['carburant'],
                                                  climatiseur:
                                                      voiture['climatiseur'],
                                                  distance: voiture['distance'],
                                                  sieges: voiture['sieges'],
                                                  portes: voiture['portes'],
                                                  cylindre: voiture['cylindre'],
                                                  images: (voiture['photos']
                                                              as List?)
                                                          ?.map((e) =>
                                                              e.toString())
                                                          .toList() ??
                                                      [],
                                                  video: voiture['video'],
                                                  videoOptimized:
                                                      voiture['videoOptimized'],
                                                  entreprise:
                                                      voiture['entreprise'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Image avec overlay
                                                Expanded(
                                                  flex: 3,
                                                  child: Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  12),
                                                          topRight:
                                                              Radius.circular(
                                                                  12),
                                                        ),
                                                        child: (voiture['photos']
                                                                        as List?)
                                                                    ?.isNotEmpty ==
                                                                true
                                                            ? Image.network(
                                                                voiture['photos']
                                                                    [0],
                                                                height: double
                                                                    .infinity,
                                                                width: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : (voiture['video'] !=
                                                                        null &&
                                                                    (voiture['video']
                                                                            ?.toString()
                                                                            .isNotEmpty ??
                                                                        false))
                                                                ? VideoPreviewPlaceholder(
                                                                    videoUrl: voiture[
                                                                            'video']
                                                                        ?.toString(),
                                                                    enablePreviewFrame:
                                                                        false,
                                                                  )
                                                                : Container(
                                                                    height: double
                                                                        .infinity,
                                                                    width: double
                                                                        .infinity,
                                                                    color: Colors
                                                                            .grey[
                                                                        300],
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .image_not_supported,
                                                                    ),
                                                                  ),
                                                      ),
                                                      // Badge condition
                                                      Positioned(
                                                        top: 8,
                                                        left: 8,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: ((voiture['condition'] ??
                                                                                '')
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        'nouveau' ||
                                                                    (voiture['condition'] ??
                                                                                '')
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        'neuf')
                                                                ? Colors.purple
                                                                : const Color(
                                                                    0xFFF8BF13),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                          ),
                                                          child: Text(
                                                            ((voiture['condition'] ??
                                                                                '')
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        'nouveau' ||
                                                                    (voiture['condition'] ??
                                                                                '')
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        'neuf')
                                                                ? 'Nouveau'
                                                                : 'Occasion',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Informations de la voiture
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    voiture['marque'] ??
                                                                        '',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  Text(
                                                                    voiture['modele']
                                                                            ?.toString() ??
                                                                        '',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      color: Colors
                                                                              .grey[
                                                                          500],
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              '${voiture['prix'] ?? ''} FCFA',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              // Rangée 1: Boite vitesse + Année
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        _buildCaracteristic(
                                                                      Icons
                                                                          .settings,
                                                                      voiture['boiteVitesse']
                                                                              ?.toString() ??
                                                                          'Automatique',
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Expanded(
                                                                    child:
                                                                        _buildCaracteristic(
                                                                      Icons
                                                                          .calendar_today,
                                                                      voiture['annee']
                                                                              ?.toString() ??
                                                                          '',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Rangée 2: Carburant + Cylindre
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        _buildCaracteristic(
                                                                      Icons
                                                                          .local_gas_station,
                                                                      voiture['carburant']
                                                                              ?.toString() ??
                                                                          '',
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Expanded(
                                                                    child:
                                                                        _buildCaracteristic(
                                                                      Icons
                                                                          .speed,
                                                                      voiture['cylindre']
                                                                              ?.toString() ??
                                                                          '',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // Rangée 3: Distance + Portes
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        _buildCaracteristic(
                                                                      Icons
                                                                          .speed,
                                                                      '${voiture['distance'] ?? ''} KM',
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Expanded(
                                                                    child:
                                                                        _buildCaracteristic(
                                                                      Icons
                                                                          .door_front_door,
                                                                      '${voiture['portes'] ?? ''} portes',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isVendeur)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                              onPressed: () {
                                                _deleteVoiture(
                                                  voiture['_id'] ?? '',
                                                  index,
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
