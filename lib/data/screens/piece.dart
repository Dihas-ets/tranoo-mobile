import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';
import 'mastervacpage.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';
import 'package:tranoo/services/alert_service.dart';
import 'package:tranoo/utils/article_view_helper.dart';
import 'package:tranoo/utils/page_refresh_registry.dart';
import 'package:tranoo/widgets/page_pull_refresh.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/utils/catalog_display.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/catalog_filter_options.dart';
import 'package:tranoo/widgets/catalog_filter_sections.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/data/repositories/catalog_repository.dart';
import 'package:tranoo/data/screens/catalog_list_controller.dart';
import 'package:tranoo/widgets/catalog_piece_grid_card.dart';
import 'package:tranoo/widgets/catalog_list_chrome.dart';

class PiecePage extends StatefulWidget {
  const PiecePage({super.key});

  @override
  State<PiecePage> createState() => _PiecePageState();
}

class _PiecePageState extends State<PiecePage>
    with SingleTickerProviderStateMixin, RegisterPageRefresh {
  @override
  Future<void> onPagePullRefresh() async => fetchPieces();

  late final CatalogListController _list;
  List<dynamic> get pieces => _list.items;
  bool get isLoading => _list.isLoading;
  String? get error => _list.error;
  List<bool> get _isVisible => _list.isVisible;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  // Filtres
  String? _selectedBrand;
  String? _selectedType;
  String? _selectedLocation;
  double? _budgetMin;
  double? _budgetMax;

  // TabController pour les filtres (acheteur uniquement)
  late TabController _tabController;
  late int _typeTabIndex;
  late int _marqueTabIndex;
  late int _localisationTabIndex;
  late int _budgetTabIndex;
  bool _noResultDialogShown = false;
  Timer? _noResultDialogTimer;

  @override
  void initState() {
    super.initState();

    _list = CatalogListController(
      articleType: 'piece',
      cacheKey: CatalogRepository.cachePieces,
      timeout: const Duration(seconds: 15),
      isMounted: () => mounted,
    );
    _list.addListener(() {
      if (mounted) setState(() {});
    });
    _list.onItemsUpdated = (items) {
      if (!mounted) return;
      precacheTranooImages(
        context,
        photoUrlsFromArticles(items.cast<Map<String, dynamic>>()),
        cloudinaryWidthPx: cloudinaryWidthPx(context, logicalWidth: 120),
      );
    };
    _list.mapError = (e) {
      if (e.isNetwork) {
        debugPrint('[PIECES_PUBLIC] fetchPieces exception: network');
      } else {
        debugPrint('[PIECES_PUBLIC] HTTP ${e.statusCode}');
      }
      final l10n = AppLocalizations.of(context)!;
      return e.isNetwork
          ? l10n.networkError
          : (e.statusCode == 401
              ? l10n.sessionExpiredReconnect
              : l10n.piecesLoadError);
    };

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
    _typeTabIndex = 0;
    _marqueTabIndex = 1;
    _localisationTabIndex = 2;
    _budgetTabIndex = 3;
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      setState(() {});
    });

    fetchPieces();
    _list.startAutoRefresh();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
        _noResultDialogShown = false;
      });
    });
  }

  @override
  void dispose() {
    _list.dispose();
    _noResultDialogTimer?.cancel();
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

  Map<String, dynamic>? _contactMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  Future<void> _reloadAll() async {
    // Réinitialiser la recherche
    _searchController.clear();
    _searchText = '';

    // Réinitialiser les filtres
    _selectedBrand = null;
    _selectedType = null;
    _selectedLocation = null;
    _budgetMin = null;
    _budgetMax = null;

    setState(() {});
    await fetchPieces();
  }

  Future<void> fetchPieces({bool silent = false}) =>
      _list.fetch(silent: silent);

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
      await _list.deleteArticle(articleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.partDeletedSuccess)),
      );
      fetchPieces();
    } on CatalogFetchException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.isNetwork ? l10n.networkOrServerError : l10n.deletionError,
          ),
        ),
      );
    }
  }

  // Appliquer les filtres
  List<dynamic> _applyFilters(List<dynamic> source) {
    return source.where((p) {
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        final marqueHaystack = [
          p['marque'],
          p['titre'],
          p['title'],
        ].map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).join(' ');
        if (marqueHaystack.isEmpty ||
            !catalogValueMatches(_selectedBrand, marqueHaystack)) {
          return false;
        }
      }
      if (_selectedType != null && _selectedType!.isNotEmpty) {
        if (!pieceMatchesTypeFilter(p, _selectedType)) return false;
      }
      if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
        final loc = [
          p['localisation'],
          p['lieu'],
          p['pays'],
          p['entreprise'],
          p['description'],
          p['titre'],
        ].map((e) => e?.toString() ?? '').join(' ');
        if (!catalogValueMatches(_selectedLocation, loc)) return false;
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
    return CatalogFilterTabButton(
      title: title,
      selected: _tabController.index == index,
      isWide: isWide,
      onTap: () => setState(() => _tabController.index = index),
    );
  }

  Widget _buildMarqueSection() {
    if (isLoading && pieces.isEmpty) {
      return const CatalogFilterHorizSkeleton();
    }
    final options = buildMarqueFilterOptions(pieces, isPiece: true);
    return CatalogMarqueFilterGrid(
      options: options,
      selected: _selectedBrand,
      onSelected: (v) => setState(() => _selectedBrand = v),
    );
  }

  Widget _buildTypeSection() {
    if (isLoading && pieces.isEmpty) {
      return const CatalogFilterHorizSkeleton(itemWidth: 76, height: 86);
    }
    return CatalogPieceTypeFilterGrid(
      selected: _selectedType,
      onSelected: (v) => setState(() => _selectedType = v),
    );
  }

  Widget _buildLocalisationSection() {
    if (isLoading && pieces.isEmpty) {
      return const CatalogFilterHorizSkeleton();
    }
    final options = buildLocationFilterOptions(pieces);
    return CatalogLocationFilterGrid(
      options: options,
      selected: _selectedLocation,
      onSelected: (v) => setState(() => _selectedLocation = v),
    );
  }

  Widget _buildBudgetSection() {
    final l10n = AppLocalizations.of(context)!;
    return CatalogBudgetFilterPanel(
      articles: pieces,
      budgetMin: _budgetMin,
      budgetMax: _budgetMax,
      countLabel: (n) => l10n.partsAvailableCount(n),
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
                                                    .pieceImages,
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
                                              child: TranooNetworkImage(
                                                url: url,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                cloudinaryWidthPx:
                                                    cloudinaryWidthPx(context,
                                                        logicalWidth: 56),
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
                                backgroundColor: const Color(0xFFF8BF13),
                                foregroundColor: Colors.black,
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

  void _scheduleNoResultDialog() {
    if (!mounted || _noResultDialogShown || _noResultDialogTimer?.isActive == true) {
      return;
    }
    _noResultDialogTimer?.cancel();
    _noResultDialogTimer = Timer(const Duration(seconds: 1), () {
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
              const Icon(Icons.search_off, color: Color(0xFFF8BF13)),
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
        _selectedType != null ||
        _selectedLocation != null ||
        _budgetMin != null ||
        _budgetMax != null;
    final filteredPieces = _applyFilters(pieces).where((p) {
      final title = (p['titre'] ?? '').toString().toLowerCase();
      return _searchText.isEmpty || title.contains(_searchText);
    }).toList();
    if (filteredPieces.isNotEmpty) {
      _noResultDialogShown = false;
      _cancelNoResultDialogTimer();
    } else if (hasActiveCriteria) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scheduleNoResultDialog();
      });
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
                    CatalogListSearchField(
                      controller: _searchController,
                      hintText: l10n.searchPartHint,
                    ),
                    CatalogFilterTabBar(
                      controller: _tabController,
                      tabs: [
                        _buildTabButton(
                          l10n.filterTypeTab,
                          _typeTabIndex,
                          isWide: true,
                        ),
                        _buildTabButton(l10n.filterBrandTab, _marqueTabIndex),
                        _buildTabButton(
                          l10n.filterLocationTab,
                          _localisationTabIndex,
                          isWide: true,
                        ),
                        _buildTabButton(l10n.budgetLabel, _budgetTabIndex),
                      ],
                    ),
                    // Sections de filtres
                    if (_tabController.index == _typeTabIndex)
                      _buildTypeSection(),
                    if (_tabController.index == _marqueTabIndex)
                      _buildMarqueSection(),
                    if (_tabController.index == _localisationTabIndex)
                      _buildLocalisationSection(),
                    if (_tabController.index == _budgetTabIndex)
                      _buildBudgetSection(),
                    // Liste des pièces
                    Expanded(
                      child: filteredPieces.isEmpty
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 32,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.build_circle_outlined,
                                                size: 56,
                                                color: Colors.grey.shade400,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                hasActiveCriteria
                                                    ? l10n.noResults
                                                    : 'Aucune pièce en ligne actuellement',
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
                                                  l10n.noPartSearchResultHint,
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
                                    ),
                                  );
                                },
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
                                    final articleMap =
                                        Map<String, dynamic>.from(piece);
                                    return AnimatedOpacity(
                                      opacity: _isVisible.length > index &&
                                              _isVisible[index]
                                          ? 1.0
                                          : 0.0,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      child: CatalogPieceGridCard.fromArticleMap(
                                        article: articleMap,
                                        title: _pieceDisplayTitle(l10n, piece),
                                        company:
                                            _pieceDisplayCompany(l10n, piece),
                                        onTap: () {
                                          trackArticleView(
                                              articleIdFromMap(articleMap));
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MastervacPage(
                                                id: (piece['_id'] ??
                                                        piece['id'] ??
                                                        piece['articleId'] ??
                                                        piece['Id'] ??
                                                        piece['article'])
                                                    ?.toString(),
                                                isAcheteur: true,
                                                title: _pieceDisplayTitle(
                                                    l10n, piece),
                                                year: piece['annee'] ?? '',
                                                description:
                                                    piece['description'] ?? '',
                                                company: _pieceDisplayCompany(
                                                    l10n, piece),
                                                location:
                                                    _pieceDisplayLocation(piece),
                                                price: piece['prix']
                                                        ?.toString() ??
                                                    '',
                                                images: (piece['photos']
                                                            as List?)
                                                        ?.map((e) =>
                                                            e.toString())
                                                        .toList() ??
                                                    [],
                                                fuelType: piece['typeMoteur'],
                                                model: piece['modele']
                                                    ?.toString(),
                                                pieceType: piece['condition'] ??
                                                    piece['pieceType'],
                                                categorie: piece['categorie']
                                                    ?.toString(),
                                                marque: piece['marque']
                                                    ?.toString(),
                                                video: piece['video'],
                                                fournisseur: _contactMap(
                                                    piece['fournisseur']),
                                                vendeur: _contactMap(
                                                    piece['vendeur']),
                                              ),
                                            ),
                                          ).then((_) => fetchPieces());
                                        },
                                      ),
                                    );                                  },
                                ),
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}

