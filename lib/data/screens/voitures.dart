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
import 'package:tranoo/utils/catalog_display.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/catalog_filter_options.dart';
import 'package:tranoo/widgets/catalog_filter_sections.dart';

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
  Timer? _noResultDialogTimer;

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
    _noResultDialogTimer?.cancel();
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
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          error = l10n.carsLoadError;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = AppLocalizations.of(context)!.networkError;
        isLoading = false;
      });
    }
  }

  Future<void> _deleteVoiture(String articleId, int index) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Text(l10n.confirmDeleteCar),
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
          SnackBar(content: Text(l10n.carDeletedSuccess)),
        );
        fetchVoitures();
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
    setState(() {
      _isVisible[index] = true;
    });
  }

  // Appliquer les filtres
  List<dynamic> _applyFilters(List<dynamic> source) {
    return source.where((v) {
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        final marque = (v['marque'] ?? '').toString();
        if (!catalogValueMatches(_selectedBrand, marque)) return false;
      }
      if (_selectedModel != null && _selectedModel!.isNotEmpty) {
        final modele = (v['modele'] ?? '').toString();
        if (!catalogValueMatches(_selectedModel, modele)) return false;
      }
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        final loc = [
          v['localisation'],
          v['lieu'],
          v['pays'],
          v['entreprise'],
          v['description'],
          v['titre'],
        ].map((e) => e?.toString() ?? '').join(' ');
        if (!catalogValueMatches(_selectedLocation, loc)) return false;
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
    if (isLoading && voitures.isEmpty) {
      return const CatalogFilterHorizSkeleton();
    }
    final options = buildMarqueFilterOptions(voitures, isPiece: false);
    return CatalogMarqueFilterGrid(
      options: options,
      selected: _selectedBrand,
      onSelected: (v) => setState(() => _selectedBrand = v),
    );
  }

  Widget _buildModeleSection() {
    if (isLoading && voitures.isEmpty) {
      return const CatalogFilterHorizSkeleton(itemWidth: 88, height: 60);
    }
    final modeles = buildModeleFilterOptions(voitures);
    return CatalogModeleFilterGrid(
      modeles: modeles,
      selected: _selectedModel,
      onSelected: (v) => setState(() => _selectedModel = v),
    );
  }

  Widget _buildLocalisationSection() {
    if (isLoading && voitures.isEmpty) {
      return const CatalogFilterHorizSkeleton();
    }
    final options = buildLocationFilterOptions(voitures);
    return CatalogLocationFilterGrid(
      options: options,
      selected: _selectedLocation,
      onSelected: (v) => setState(() => _selectedLocation = v),
    );
  }

  Widget _buildBudgetSection() {
    final l10n = AppLocalizations.of(context)!;
    return CatalogBudgetFilterPanel(
      articles: voitures,
      budgetMin: _budgetMin,
      budgetMax: _budgetMax,
      countLabel: (n) => l10n.vehiclesAvailableCount(n),
      onReset: () => setState(() {
        _budgetMin = null;
        _budgetMax = null;
      }),
      onApply: (min, max) => setState(() {
        _budgetMin = min;
        _budgetMax = max;
      }),
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
    final l10n = AppLocalizations.of(context)!;
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
                                Text(
                                  l10n.vehicleAlert,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                        label: Text(l10n.addImages),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFF8BF13),
                                          foregroundColor: Colors.black,
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
                                  decoration: InputDecoration(
                                    labelText: l10n.brand,
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
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
                                  validator: (v) => (v == null || v.trim().isEmpty)
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
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? l10n.yearRequired
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.vehicleCondition,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l10n.newCondition),
                                  value: 'neuf',
                                  groupValue: etat,
                                  onChanged: (value) =>
                                      setSheetState(() => etat = value ?? 'neuf'),
                                ),
                                RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l10n.usedCondition),
                                  value: 'occasion',
                                  groupValue: etat,
                                  onChanged: (value) =>
                                      setSheetState(() => etat = value ?? 'occasion'),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: budgetController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.budgetFcfa,
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? l10n.budgetRequired
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
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text(l10n.ok),
                                        ),
                                      ],
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.alertSendError('$e')),
                                    ),
                                  );
                                }
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

  void _scheduleNoResultDialog() {
    if (!mounted || _noResultDialogShown || _noResultDialogTimer?.isActive == true) {
      return;
    }
    _noResultDialogTimer?.cancel();
    _noResultDialogTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _noResultDialogShown) return;
      _showNoResultDialog();
    });
  }

  void _cancelNoResultDialogTimer() {
    _noResultDialogTimer?.cancel();
    _noResultDialogTimer = null;
  }

  void _showNoResultDialog() {
    if (!mounted || _noResultDialogShown) return;
    _noResultDialogShown = true;
    final l10n = AppLocalizations.of(context)!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.search_off, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Text(l10n.noResults),
            ],
          ),
          content: Text(l10n.noVehicleSearchResultHint),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.later),
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
      _cancelNoResultDialogTimer();
    } else if (hasActiveCriteria) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scheduleNoResultDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.carsOnline),
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
                          hintText: l10n.searchCarHint,
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
                    // Liste des voitures
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => fetchVoitures(silent: true),
                        child: filteredVoitures.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height * 0.12,
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_car_outlined,
                                            size: 56,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            hasActiveCriteria
                                                ? l10n.noResults
                                                : 'Aucune voiture disponible pour le moment.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          if (hasActiveCriteria) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              l10n.noVehicleSearchResultHint,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
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
                                                                  ? l10n.conditionNew
                                                                  : l10n.usedCondition,
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
                                                          catalogVehicleInfoFooter(
                                                            title: vehicleTitleFromMap(
                                                              Map<String, dynamic>.from(voiture),
                                                            ),
                                                            prix: voiture['prix'],
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
                                                                            l10n.automaticTransmission,
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
                    if (_tabController.index == _budgetTabIndex)
                      _buildBudgetSection(),
                  ],
                ),
      ),
    );
  }
}
