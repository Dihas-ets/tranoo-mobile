import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mastervacpage.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';
import 'package:tranoo/services/alert_service.dart';
import 'package:tranoo/utils/article_view_helper.dart';
import 'package:tranoo/utils/page_refresh_registry.dart';
import 'package:tranoo/widgets/page_pull_refresh.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/utils/catalog_display.dart';
import 'package:tranoo/l10n/app_localizations.dart';

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

class PiecePage extends StatefulWidget {
  const PiecePage({super.key});

  @override
  State<PiecePage> createState() => _PiecePageState();
}

class _PiecePageState extends State<PiecePage>
    with SingleTickerProviderStateMixin, RegisterPageRefresh {
  @override
  Future<void> onPagePullRefresh() async => fetchPieces();
  List<dynamic> pieces = [];
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
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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

    fetchPieces();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) fetchPieces(silent: true);
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

  String _pieceDisplayTitle(AppLocalizations l10n, dynamic piece) {
    final t = piece['titre'];
    if (t != null && t.toString().trim().isNotEmpty) return t.toString();
    final pt = piece['pieceType'];
    if (pt != null && pt.toString().trim().isNotEmpty) return pt.toString();
    return l10n.untitled;
  }

  String _pieceDisplayCompany(AppLocalizations l10n, dynamic piece) {
    final e = piece['entreprise'];
    if (e != null && e.toString().trim().isNotEmpty) return e.toString();
    final v = piece['vendeur'];
    if (v is Map) {
      final ve = v['entreprise'];
      if (ve != null && ve.toString().trim().isNotEmpty) return ve.toString();
      final n = v['nom'];
      final p = v['prenoms'];
      final both = '${n ?? ''} ${p ?? ''}'.trim();
      if (both.isNotEmpty) return both;
    }
    return l10n.unknownCompany;
  }

  String _pieceDisplayLocation(dynamic piece) {
    final a = piece['localisation']?.toString().trim();
    if (a != null && a.isNotEmpty) return a;
    final b = piece['lieu']?.toString().trim();
    if (b != null && b.isNotEmpty) return b;
    return '';
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
    await fetchPieces();
  }

  Future<void> fetchPieces({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      String url = getBaseUrl() + '/public/articles?type=piece';
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
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          pieces = data;
          _isVisible = List.generate(data.length, (index) => true);
          isLoading = false;
        });
      } else {
        debugPrint(
            '[PIECES_PUBLIC] HTTP ${response.statusCode}: ${response.body}');
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          error = response.statusCode == 401
              ? l10n.sessionExpiredReconnect
              : l10n.piecesLoadError;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[PIECES_PUBLIC] fetchPieces exception: $e');
      if (!mounted) return;
      setState(() {
        error = AppLocalizations.of(context)!.networkError;
        isLoading = false;
      });
    }
  }

  Future<void> _deletePiece(String articleId, int index) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Text(l10n.confirmDeletePart),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
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
          SnackBar(content: Text(l10n.partDeletedSuccess)),
        );
        fetchPieces();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deletionError)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.networkOrServerError)),
      );
    }
  }

  // Appliquer les filtres
  List<dynamic> _applyFilters(List<dynamic> source) {
    return source.where((p) {
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        final marque =
            (p['marque'] ?? p['pieceType'] ?? '').toString().toLowerCase();
        if (!marque.contains(_selectedBrand!.toLowerCase())) {
          return false;
        }
      }
      if (_selectedModel != null && _selectedModel!.isNotEmpty) {
        final modele = (p['modele'] ?? '').toString().toLowerCase();
        if (!modele.contains(_selectedModel!.toLowerCase())) {
          return false;
        }
      }
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        final loc = ((p['localisation'] ?? '') + ' ' + (p['entreprise'] ?? ''))
            .toLowerCase();
        if (!loc.contains(_selectedLocation!.toLowerCase()) &&
            !((p['titre'] ?? '')
                .toString()
                .toLowerCase()
                .contains(_selectedLocation!.toLowerCase()))) {
          return false;
        }
      }
      if (_budgetMin != null || _budgetMax != null) {
        final prixStr = (p['prix'] ?? '').toString();
        final price =
            double.tryParse(prixStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (_budgetMin != null && price < _budgetMin!) return false;
        if (_budgetMax != null && price > _budgetMax!) return false;
      }
      return true;
    }).toList();
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
                      child: Image.asset(item["image"], fit: BoxFit.contain),
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
          child: Text(AppLocalizations.of(context)!.filterByBudget),
        ),
      ),
    );
  }

  void _openBudgetSheet() {
    final List<double> prixList = pieces
        .map((p) => double.tryParse(
            (p['prix'] ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), '')))
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
      return pieces.where((p) {
        final prix = double.tryParse(
            (p['prix'] ?? '').toString().replaceAll(RegExp(r'[^0-9.]'), ''));
        if (prix == null) return false;
        return prix >= a && prix <= b;
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
        final l10n = AppLocalizations.of(context)!;
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
                    Text(
                      l10n.priceFcfa,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minCtl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.minLabel,
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
                              labelText: l10n.maxLabel,
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
                    Text(l10n.partsAvailableCount(disponibles)),
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
                            child: Text(l10n.reset),
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
                            child: Text(l10n.apply),
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

  Future<void> _showPieceMiniForm() async {
    final formKey = GlobalKey<FormState>();
    final marqueController = TextEditingController();
    final modeleController = TextEditingController();
    final anneeController = TextEditingController();
    final pieceNameController = TextEditingController();
    String urgence = 'normale';
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
        final l10n = AppLocalizations.of(ctx)!;
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
                                Text(
                                  l10n.partAlert,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                                      .pieceImages,
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
                                        label: Text(l10n.addImages),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFE57373),
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: l10n.takePhoto,
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
                                                    .pieceImages,
                                              );
                                              setSheetState(() {
                                                alertPhotoUrls.addAll(uploaded);
                                                alertPhotosUploading = false;
                                              });
                                            },
                                      icon: const Icon(Icons.photo_camera),
                                      color: const Color(0xFFE57373),
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
                                  decoration: InputDecoration(
                                    labelText: l10n.vehicleBrandLabel,
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? l10n.brandRequired
                                          : null,
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: modeleController,
                                  decoration: InputDecoration(
                                    labelText: l10n.model,
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? l10n.modelRequired
                                          : null,
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: anneeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.year,
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? l10n.yearRequired
                                          : null,
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: pieceNameController,
                                  decoration: InputDecoration(
                                    labelText: l10n.partNameLabel,
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? l10n.partNameRequired
                                          : null,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.urgencyLevel,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l10n.urgencyLow),
                                  value: 'faible',
                                  groupValue: urgence,
                                  onChanged: (value) => setSheetState(
                                      () => urgence = value ?? 'faible'),
                                ),
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l10n.urgencyNormal),
                                  value: 'normale',
                                  groupValue: urgence,
                                  onChanged: (value) => setSheetState(
                                      () => urgence = value ?? 'normale'),
                                ),
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l10n.urgencyHigh),
                                  value: 'urgente',
                                  groupValue: urgence,
                                  onChanged: (value) => setSheetState(
                                      () => urgence = value ?? 'urgente'),
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
                                backgroundColor: const Color(0xFFE57373),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: alertPhotosUploading
                                  ? null
                                  : () {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                                () async {
                                  try {
                                    await AlertService().createPieceAlert(
                                      marque: marqueController.text,
                                      modele: modeleController.text,
                                      annee: anneeController.text,
                                      pieceName: pieceNameController.text,
                                      urgence: urgence,
                                      photos: alertPhotoUrls,
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(ctx);
                                    await showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        title: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF16A34A),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(l10n.alertSent),
                                          ],
                                        ),
                                        content: Text(l10n.alertRegisteredFeedback),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text(l10n.ok),
                                          ),
                                        ],
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            l10n.alertSendError('$e')),
                                      ),
                                    );
                                  }
                                }();
                              },
                              child: Text(l10n.sendAlert),
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
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.search_off, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Text(l10n.noResults),
            ],
          ),
          content: Text(l10n.noPartSearchResultHint),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.later),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showPieceMiniForm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8BF13),
                foregroundColor: Colors.black,
              ),
              child: Text(l10n.fillMiniForm),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasActiveCriteria = _searchText.trim().isNotEmpty ||
        _selectedBrand != null ||
        _selectedModel != null ||
        _selectedLocation != null ||
        _budgetMin != null ||
        _budgetMax != null;
    final filteredPieces = _applyFilters(pieces).where((p) {
      final title = (p['titre'] ?? '').toString().toLowerCase();
      return _searchText.isEmpty || title.contains(_searchText);
    }).toList();
    if (filteredPieces.isNotEmpty) {
      _noResultDialogShown = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.spareParts),
        backgroundColor: Colors.amber,
      ),
      body: PagePullRefresh(
        onRefresh: () => fetchPieces(),
        refreshSkeleton: SkeletonPresets.fullPageList(),
        child: isLoading && pieces.isEmpty
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
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchPartHint,
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
                    // Liste des pièces
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _reloadAll,
                        child: filteredPieces.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Builder(
                                    builder: (_) {
                                      if (hasActiveCriteria) {
                                        _showNoResultDialog();
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.22,
                                  ),
                                  const Center(
                                    child: Text(
                                      "Aucune pièce en ligne actuellement",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: GridView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.78,
                                  ),
                                  itemCount: filteredPieces.length,
                                  itemBuilder: (context, index) {
                                    final piece = filteredPieces[index];
                                    final pieceId = piece['_id'] ?? '';
                                    return AnimatedOpacity(
                                      opacity: _isVisible.length > index &&
                                              _isVisible[index]
                                          ? 1.0
                                          : 0.0,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              final articleMap =
                                                  Map<String, dynamic>.from(
                                                      piece);
                                              trackArticleView(
                                                  articleIdFromMap(articleMap));
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MastervacPage(
                                                    id: (piece['_id'] ??
                                                            piece['id'] ??
                                                            piece[
                                                                'articleId'] ??
                                                            piece['Id'] ??
                                                            piece['article'])
                                                        ?.toString(),
                                                    isAcheteur: true,
                                                    title: _pieceDisplayTitle(
                                                        l10n, piece),
                                                    year: piece['annee'] ?? '',
                                                    description:
                                                        piece['description'] ??
                                                            '',
                                                    company:
                                                        _pieceDisplayCompany(
                                                            l10n, piece),
                                                    location:
                                                        _pieceDisplayLocation(
                                                            piece),
                                                    price: piece['prix']
                                                            ?.toString() ??
                                                        '',
                                                    images: (piece['photos']
                                                                as List?)
                                                            ?.map((e) =>
                                                                e.toString())
                                                            .toList() ??
                                                        [],
                                                    fuelType:
                                                        piece['typeMoteur'],
                                                    model: piece['modele']
                                                        ?.toString(),
                                                    pieceType:
                                                        piece['pieceType'],
                                                    video: piece['video'],
                                                  ),
                                                ),
                                              ).then((_) => fetchPieces());
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12
                                                        .withOpacity(0.08),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: SizedBox(
                                                      height: 100,
                                                      width: double.infinity,
                                                      child: Stack(
                                                        children: [
                                                          Positioned.fill(
                                                            child: (piece['photos']
                                                                            as List?)
                                                                        ?.isNotEmpty ==
                                                                    true
                                                                ? Image.network(
                                                                    piece['photos']
                                                                        [0],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : (piece['video'] !=
                                                                            null &&
                                                                        (piece['video']?.toString().isNotEmpty ??
                                                                            false))
                                                                    ? VideoPreviewPlaceholder(
                                                                        videoUrl:
                                                                            piece['video']?.toString(),
                                                                        iconSize:
                                                                            36,
                                                                      )
                                                                    : Container(
                                                                        color: Colors
                                                                            .grey[200],
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .image_not_supported,
                                                                          size:
                                                                              30,
                                                                          color:
                                                                              Colors.black26,
                                                                        ),
                                                                      ),
                                                          ),
                                                          Positioned(
                                                            bottom: 6,
                                                            right: 6,
                                                            child:
                                                                buildArticleViewBadge(
                                                              articleViewsFromMap(
                                                                Map<String,
                                                                        dynamic>.from(
                                                                    piece),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _pieceDisplayTitle(l10n, piece),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _pieceDisplayCompany(l10n, piece),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  catalogPiecePricePill(piece['prix']),
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
