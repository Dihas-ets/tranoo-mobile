// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cars_info.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/data/screens/cars_info.dart';
import 'package:tranoo/services/alert_service.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';
import 'package:tranoo/utils/article_view_helper.dart';
import 'package:tranoo/utils/page_refresh_registry.dart';
import 'package:tranoo/widgets/page_pull_refresh.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';

// Fonction utilitaire pour formater les prix avec des séparateurs de milliers
String formatPrice(dynamic price) {
  if (price == null) return '0';
  try {
    final priceNum = double.tryParse(price.toString()) ?? 0;
    final priceStr = priceNum.toStringAsFixed(0);
    final reversed = priceStr.split('').reversed.join('');
    final withDots = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (Match m) => '${m[0]}.',
    );
    return withDots.split('').reversed.join('');
  } catch (e) {
    return price.toString();
  }
}

class VoituresPage extends StatefulWidget {
  const VoituresPage({super.key});

  @override
  State<VoituresPage> createState() => _VoituresPageState();
}

class _VoituresPageState extends State<VoituresPage>
    with SingleTickerProviderStateMixin, RegisterPageRefresh {
  @override
  Future<void> onPagePullRefresh() async => fetchVoitures();
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

  // TabController pour les filtres (acheteur uniquement)
  late TabController _tabController;
  late int _marqueTabIndex;
  late int _modeleTabIndex;
  late int _localisationTabIndex;
  late int _budgetTabIndex;
  Timer? _autoRefreshTimer;
  bool _noResultDialogShown = false;

  @override
  void initState() {
    super.initState();

    // Récupérer le paramètre de recherche si disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['searchQuery'] != null) {
        setState(() {
          _searchController.text = args['searchQuery'];
          _searchText = args['searchQuery'].toString().toLowerCase();
        });
      }
    });

    // Initialisation des indices des onglets (acheteur)
    _marqueTabIndex = 0;
    _modeleTabIndex = 1;
    _localisationTabIndex = 2;
    _budgetTabIndex = 3;
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      setState(() {});
    });

    fetchVoitures();
    _autoRefreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) fetchVoitures(silent: true);
    });
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
        _noResultDialogShown = false;
      });
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? _voitureDisplayCompany(dynamic v) {
    final e = v['entreprise'];
    if (e != null && e.toString().trim().isNotEmpty) return e.toString();
    final vend = v['vendeur'];
    if (vend is Map) {
      final ve = vend['entreprise'];
      if (ve != null && ve.toString().trim().isNotEmpty) return ve.toString();
      final n = vend['nom'];
      final p = vend['prenoms'];
      final both = '${n ?? ''} ${p ?? ''}'.trim();
      if (both.isNotEmpty) return both;
    }
    return null;
  }

  double _computeCardAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 0.58;
    if (screenWidth < 420) return 0.59;
    if (screenWidth < 520) return 0.7;
    return 0.78;
  }

  Future<void> _reloadAll() async {
    // Réinitialiser la recherche
    _searchController.clear();
    _searchText = '';

    // Réinitialiser les filtres
    _selectedBrand = null;
    _selectedModel = null;
    _selectedLocation = null;
    _budgetMin = null;
    _budgetMax = null;

    setState(() {});
    await fetchVoitures();
  }

  Future<void> fetchVoitures({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url = getBaseUrl() + '/public/articles?type=voiture';
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));
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
    setState(() {
      _isVisible[index] = true;
    });
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
        height: 70 + 16,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 70,
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
        height: 60 + 16,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 80,
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
                      height: 36,
                      child: Image.asset(
                        item["image"],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item["name"],
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
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
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final disponibles = compterDansIntervalle(currentMin, currentMax);
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16 + 12,
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
                              backgroundColor: const Color(0xFFE57373),
                              foregroundColor: Colors.white,
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
              ),
            );
          },
        );
      },
    );
  }

  Future<List<String>> _uploadAlertPhotos(
    List<XFile> files, {
    required String folder,
  }) async {
    final urls = <String>[];
    for (final file in files.take(6)) {
      final url = await uploadImageToCloudinary(
        File(file.path),
        folder: folder,
      );
      if (url != null && url.isNotEmpty) urls.add(url);
    }
    return urls;
  }

  Future<void> _showVehicleMiniForm() async {
    final formKey = GlobalKey<FormState>();
    final marqueController = TextEditingController();
    final modeleController = TextEditingController();
    final anneeController = TextEditingController();
    final budgetController = TextEditingController();
    String etat = 'occasion';
    final alertPhotoUrls = <String>[];
    var alertPhotosUploading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              top: false,
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.78,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.of(ctx).viewInsets.bottom + 16,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 42,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Alerte vehicule',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: alertPhotosUploading
                                            ? null
                                            : () async {
                                                final picker = ImagePicker();
                                                final images =
                                                    await picker.pickMultiImage();
                                                if (images.isEmpty) return;
                                                setSheetState(() =>
                                                    alertPhotosUploading =
                                                        true);
                                                final uploaded =
                                                    await _uploadAlertPhotos(
                                                  images,
                                                  folder: CloudinaryFolders
                                                      .vehicleImages,
                                                );
                                                setSheetState(() {
                                                  alertPhotoUrls.addAll(
                                                      uploaded);
                                                  alertPhotosUploading =
                                                      false;
                                                });
                                              },
                                        icon: const Icon(
                                            Icons.add_photo_alternate,
                                            size: 20),
                                        label: const Text('Ajouter des images'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFF8BF13),
                                          foregroundColor: Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Prendre une photo',
                                      onPressed: alertPhotosUploading
                                          ? null
                                          : () async {
                                              final picker = ImagePicker();
                                              final photo = await picker
                                                  .pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              if (photo == null) return;
                                              setSheetState(() =>
                                                  alertPhotosUploading = true);
                                              final uploaded =
                                                  await _uploadAlertPhotos(
                                                [photo],
                                                folder: CloudinaryFolders
                                                    .vehicleImages,
                                              );
                                              setSheetState(() {
                                                alertPhotoUrls.addAll(uploaded);
                                                alertPhotosUploading = false;
                                              });
                                            },
                                      icon: const Icon(Icons.photo_camera),
                                      color: const Color(0xFFF8BF13),
                                    ),
                                  ],
                                ),
                                if (alertPhotosUploading)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: LinearProgressIndicator(),
                                  ),
                                if (alertPhotoUrls.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: alertPhotoUrls
                                          .map(
                                            (url) => ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                url,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: marqueController,
                                  decoration: const InputDecoration(
                                    labelText: 'Marque',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Marque requise'
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: modeleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Modele',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Modele requis'
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: anneeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Annee',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Annee requise'
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Etat du vehicule',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Neuf'),
                                  value: 'neuf',
                                  groupValue: etat,
                                  onChanged: (value) =>
                                      setSheetState(() => etat = value ?? 'neuf'),
                                ),
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Occasion'),
                                  value: 'occasion',
                                  groupValue: etat,
                                  onChanged: (value) =>
                                      setSheetState(() => etat = value ?? 'occasion'),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: budgetController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Budget (FCFA)',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Budget requis'
                                      : null,
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF8BF13),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: alertPhotosUploading
                                  ? null
                                  : () async {
                                if (!(formKey.currentState?.validate() ?? false)) {
                                  return;
                                }
                                try {
                                  await AlertService().createVehicleAlert(
                                    marque: marqueController.text,
                                    modele: modeleController.text,
                                    annee: anneeController.text,
                                    etat: etat,
                                    budgetMax: budgetController.text,
                                    photos: alertPhotoUrls,
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(ctx);
                                  await showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF16A34A),
                                          ),
                                          SizedBox(width: 8),
                                          Text('Alerte envoyée'),
                                        ],
                                      ),
                                      content: const Text(
                                        'Votre demande a bien ete enregistree. Vous recevrez les retours des vendeurs tres bientot.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur envoi alerte: $e'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Envoyer l\'alerte'),
                            ),
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
      },
    );
  }

  void _showNoResultDialog() {
    if (!mounted || _noResultDialogShown) return;
    _noResultDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.search_off, color: Color(0xFFB45309)),
              SizedBox(width: 8),
              Text('Aucun resultat'),
            ],
          ),
          content: const Text(
            'Aucune voiture ne correspond a votre recherche.\nCreez une mini alerte pour etre contacte rapidement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showVehicleMiniForm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8BF13),
                foregroundColor: Colors.black,
              ),
              child: const Text('Remplir mini form'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveCriteria = _searchText.trim().isNotEmpty ||
        _selectedBrand != null ||
        _selectedModel != null ||
        _selectedLocation != null ||
        _budgetMin != null ||
        _budgetMax != null;
    final filteredVoitures = _applyFilters(voitures).where((v) {
      final titre = ((v['marque'] ?? '').toString() +
              ' ' +
              (v['modele']?.toString() ?? ''))
          .toLowerCase();
      final alt = (v['titre'] ?? '').toString().toLowerCase();
      if (_searchText.isEmpty) return true;
      return titre.contains(_searchText) || alt.contains(_searchText);
    }).toList();
    if (filteredVoitures.isNotEmpty) {
      _noResultDialogShown = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voitures en ligne'),
        backgroundColor: Colors.amber,
        actions: const [],
      ),
      body: PagePullRefresh(
        onRefresh: () => fetchVoitures(),
        refreshSkeleton: SkeletonPresets.fullPageList(),
        child: isLoading && voitures.isEmpty
            ? SkeletonPresets.fullPageList()
            : error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.35,
                        child: Center(child: Text(error!)),
                      ),
                    ],
                  )
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
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // Filtres TabBar (acheteur)
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
                            _buildTabButton(
                              "Localisation",
                              _localisationTabIndex,
                              isWide: true,
                            ),
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
                    if (_tabController.index == _localisationTabIndex)
                      _buildLocalisationSection(),
                    if (_tabController.index == _budgetTabIndex)
                      _buildBudgetSection(),
                    // Liste des voitures
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _reloadAll,
                        child: filteredVoitures.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Builder(
                                    builder: (_) {
                                      if (hasActiveCriteria && filteredVoitures.isEmpty) {
                                        _showNoResultDialog();
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  const SizedBox(
                                    height: 250,
                                  ),
                                  const Center(
                                    child: Text(
                                      "Aucune voiture disponible pour le moment.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13.0),
                                child: GridView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
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
                                              final articleMap =
                                                  Map<String, dynamic>.from(voiture);
                                              trackArticleView(
                                                  articleIdFromMap(articleMap));
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
                                                        _voitureDisplayCompany(
                                                                voiture) ??
                                                            voiture['entreprise']
                                                                ?.toString(),
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
                                                                      videoUrl: voiture['video']
                                                                          ?.toString(),
                                                                      iconSize: 36,
                                                                      enablePreviewFrame: false,
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
                                                        Positioned(
                                                          bottom: 8,
                                                          right: 8,
                                                          child: buildArticleViewBadge(
                                                            articleViewsFromMap(
                                                              Map<String, dynamic>.from(voiture),
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
                                                                      style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: Colors.grey[600],
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow:
                                                                          TextOverflow.ellipsis,
                                                                    ),
                                                                    Text(
                                                                      voiture['modele']
                                                                              ?.toString() ??
                                                                          '',
                                                                      style: TextStyle(
                                                                        fontSize: 10,
                                                                        color: Colors.grey[500],
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow:
                                                                          TextOverflow.ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                '${formatPrice(voiture['prix'])} FCFA',
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
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}