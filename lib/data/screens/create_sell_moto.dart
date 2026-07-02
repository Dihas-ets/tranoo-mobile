import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/providers/auth_provider.dart' as local_auth;
import 'package:tranoo/services/seller_profile_locations.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/amount_display.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';

import 'moto_info.dart';
import 'movie.dart';

class CreateSellMotoPage extends StatefulWidget {
  final bool editMode;
  final String? editArticleId;
  final Map<String, dynamic>? initialData;

  const CreateSellMotoPage({
    super.key,
    this.editMode = false,
    this.editArticleId,
    this.initialData,
  });

  @override
  State<CreateSellMotoPage> createState() => _CreateSellMotoPageState();
}

class _CreateSellMotoPageState extends State<CreateSellMotoPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  static const int _maxMediaSlots = 12;
  static const int _maxVideoSlots = 3;

  // 1. Identification
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();
  final _anneeController = TextEditingController();
  final _cylindreeController = TextEditingController();
  String? _selectedTypeMoto;

  // 2. Caractéristiques techniques
  String? _selectedTypeMoteur;
  final _puissanceController = TextEditingController();
  String? _selectedTransmission;
  String? _selectedDemarrage;
  String? _selectedRefroidissement;
  final _capaciteReservoirController = TextEditingController();
  final _autonomieController = TextEditingController();

  // 3. Informations commerciales
  final _prixController = TextEditingController();
  String _selectedDevise = 'XOF';
  String? _selectedDisponibilite;
  bool _garantieConstructeur = false;
  static const _garantieMoisOptions = [6, 12, 18, 24, 36];
  int _garantieMoisIndex = 1;

  // Visuels
  final _descriptionController = TextEditingController();

  // Équipements
  final Set<String> _equipementsSelectionnes = {};

  final TextEditingController _localisationController = TextEditingController();
  final TextEditingController _fournisseurTelController =
      TextEditingController();

  double? _fournisseurLatitude;
  double? _fournisseurLongitude;
  String _fournisseurAddress = '';
  String _fournisseurCity = '';
  bool _loadingPhone = true;
  String _entreprise = '';

  // Médias
  List<String?> _cloudinaryImageUrls = List.filled(_maxMediaSlots, null);
  List<bool> _isUploadingImage = List.filled(_maxMediaSlots, false);
  List<String?> _cloudinaryVideoUrls = List.filled(_maxVideoSlots, null);
  List<bool> _isUploadingVideo = List.filled(_maxVideoSlots, false);
  final PageController _videoPageController = PageController();
  int _currentVideoIndex = 0;

  static const _typesMoto = [
    'Scooter',
    'Routière',
    'Sportive',
    'Trail',
    'Cross',
    'Tricycle',
  ];
  static const _typesMoteur = ['Essence', 'Électrique'];
  static const _transmissions = ['Manuelle', 'Semi-automatique', 'Automatique'];
  static const _demarrages = ['Électrique', 'Kick', 'Les deux'];
  static const _refroidissements = ['Air', 'Liquide'];
  static const _disponibilites = ['En stock', 'Sur commande'];
  static const _devises = ['XOF', 'EUR', 'USD'];
  static const _equipementsOptions = [
    'ABS',
    'LED',
    'GPS intégré',
    'Tableau digital',
    'USB charge',
    'Alarme',
    'Démarrage sans clé',
    'Coffre / top case inclus',
  ];

  bool get _isAnyUploading =>
      _isUploadingImage.any((e) => e) || _isUploadingVideo.any((e) => e);

  @override
  void initState() {
    super.initState();
    final init = widget.initialData;
    if (widget.editMode && init != null) {
      _hydrateFromInitialData();
      _localisationController.text =
          (init['lieu'] ?? init['localisation'] ?? '').toString();
      final fournisseur = init['fournisseur'] is Map
          ? Map<String, dynamic>.from(init['fournisseur'] as Map)
          : <String, dynamic>{};
      _fournisseurTelController.text =
          (fournisseur['telephone'] ?? '').toString();
      final lat = fournisseur['latitude'];
      final lng = fournisseur['longitude'];
      _fournisseurLatitude =
          lat is num ? lat.toDouble() : double.tryParse('$lat');
      _fournisseurLongitude =
          lng is num ? lng.toDouble() : double.tryParse('$lng');
      _fournisseurAddress = (fournisseur['adresseTexte'] ?? '').toString();
      if (_fournisseurAddress.isEmpty) {
        _fournisseurAddress = _localisationController.text.trim();
      }
      _loadingPhone = false;
    } else {
      _loadLocationsFromProfile();
    }
  }

  void _hydrateFromInitialData() {
    final init = widget.initialData;
    if (!widget.editMode || init == null) return;
    _marqueController.text = (init['marque'] ?? '').toString();
    _modeleController.text = (init['modele'] ?? '').toString();
    _anneeController.text = (init['annee'] ?? '').toString();
    _cylindreeController.text = (init['cylindre'] ?? '').toString();
    _selectedTypeMoto = init['typeMoto']?.toString();
    _selectedTypeMoteur = init['typeMoteur']?.toString();
    _puissanceController.text = (init['puissance'] ?? '').toString();
    _selectedTransmission = init['transmission']?.toString();
    _selectedDemarrage = init['demarrage']?.toString();
    _selectedRefroidissement = init['refroidissement']?.toString();
    _capaciteReservoirController.text =
        (init['capaciteReservoir'] ?? '').toString();
    _autonomieController.text = (init['autonomie'] ?? '').toString();
    _prixController.text = (init['prix'] ?? '').toString();
    _selectedDevise = init['devise']?.toString() ?? 'XOF';
    _selectedDisponibilite = init['disponibilite']?.toString();
    _garantieConstructeur = init['garantieConstructeur'] == true;
    final duree = (init['dureeGarantie'] ?? '').toString();
    final dureeNum = int.tryParse(duree.replaceAll(RegExp(r'[^0-9]'), ''));
    if (dureeNum != null) {
      final idx = _garantieMoisOptions.indexOf(dureeNum);
      if (idx >= 0) _garantieMoisIndex = idx;
    }
    _descriptionController.text = (init['description'] ?? '').toString();
    if (init['equipements'] is List) {
      _equipementsSelectionnes.addAll(
        (init['equipements'] as List).map((e) => e.toString()),
      );
    }
    if (init['photos'] is List) {
      final urls = (init['photos'] as List)
          .map((e) => e?.toString())
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();
      for (var i = 0; i < urls.length && i < _cloudinaryImageUrls.length; i++) {
        _cloudinaryImageUrls[i] = urls[i];
      }
    }
    if (init['video'] != null) {
      _cloudinaryVideoUrls[0] = init['video']?.toString();
    }
  }

  Future<void> _loadLocationsFromProfile() async {
    setState(() => _loadingPhone = true);
    final profile = await SellerProfileLocations.load();
    if (!mounted) return;
    if (profile != null) {
      setState(() {
        _fournisseurTelController.text = profile.fournisseurTel;
        _fournisseurLatitude = profile.fournisseurLat ?? profile.sellerLat;
        _fournisseurLongitude = profile.fournisseurLng ?? profile.sellerLng;
        _fournisseurAddress = profile.fournisseurAddress.isNotEmpty
            ? profile.fournisseurAddress
            : profile.sellerAddress;
        _fournisseurCity = profile.fournisseurCity.isNotEmpty
            ? profile.fournisseurCity
            : profile.sellerCity;
        _localisationController.text = _fournisseurAddress;
        _loadingPhone = false;
      });
      return;
    }
    await _prefillSupplierPhone();
  }

  Future<void> _prefillSupplierPhone() async {
    if (widget.editMode && _fournisseurTelController.text.isNotEmpty) {
      if (mounted) setState(() => _loadingPhone = false);
      return;
    }
    try {
      final cached = await local_auth.AuthProvider.loadUserFromPrefs();
      final cachedTel = cached?['telephone']?.toString().trim() ?? '';
      final cachedEntreprise = cached?['entreprise']?.toString().trim() ?? '';
      if (cachedEntreprise.isNotEmpty) _entreprise = cachedEntreprise;
      if (cachedTel.isNotEmpty) {
        if (mounted) {
          setState(() {
            _fournisseurTelController.text = cachedTel;
            _loadingPhone = false;
          });
        }
        return;
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _loadingPhone = false);
        return;
      }
      final idToken = await user.getIdToken();
      final resp = await Dio(
        BaseOptions(
          baseUrl: UserService().dio.options.baseUrl,
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      ).get('/protected/me');
      final userData = resp.data['user'];
      final tel = userData?['telephone']?.toString().trim() ?? '';
      final entreprise = userData?['entreprise']?.toString().trim() ?? '';
      if (mounted) {
        setState(() {
          if (tel.isNotEmpty) _fournisseurTelController.text = tel;
          if (entreprise.isNotEmpty) _entreprise = entreprise;
          _loadingPhone = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPhone = false);
    }
  }

  Map<String, dynamic>? get _fournisseurPayload {
    if (_fournisseurLatitude == null || _fournisseurLongitude == null) {
      return null;
    }
    return {
      'telephone': _fournisseurTelController.text.trim(),
      'latitude': _fournisseurLatitude,
      'longitude': _fournisseurLongitude,
      'adresseTexte': _fournisseurAddress,
    };
  }

  String get _effectiveLieu => _fournisseurAddress;

  String get _dureeGarantieLabel =>
      '${_garantieMoisOptions[_garantieMoisIndex]} mois';

  Future<void> _pickMultipleImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isEmpty) return;
    var slot = _cloudinaryImageUrls.indexWhere((u) => u == null || u.isEmpty);
    if (slot < 0) slot = 0;
    for (final img in images) {
      if (slot >= _maxMediaSlots) break;
      setState(() => _isUploadingImage[slot] = true);
      String? url;
      if (kIsWeb) {
        final bytes = await img.readAsBytes();
        url = await _uploadImageWeb(bytes);
      } else {
        url = await uploadImageToCloudinary(
          File(img.path),
          folder: CloudinaryFolders.vehicleImages,
        );
      }
      if (!mounted) return;
      setState(() {
        _cloudinaryImageUrls[slot] = url;
        _isUploadingImage[slot] = false;
      });
      slot++;
    }
  }

  Future<String?> _uploadImageWeb(Uint8List bytes) async {
    const cloudName = 'dy0raj5bh';
    const uploadPreset = 'unsigned_preset';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = CloudinaryFolders.vehicleImages
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'upload.jpg'),
      );
    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      return (jsonDecode(body) as Map)['secure_url'] as String?;
    }
    return null;
  }

  Future<void> _pickVideo(int index) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    setState(() => _isUploadingVideo[index] = true);
    String? url;
    if (kIsWeb) {
      final bytes = await video.readAsBytes();
      url = await uploadVideoToCloudinaryWeb(
        bytes,
        folder: CloudinaryFolders.vehicleVideos,
      );
    } else {
      url = await uploadVideoToCloudinary(
        File(video.path),
        folder: CloudinaryFolders.vehicleVideos,
      );
    }
    if (!mounted) return;
    setState(() {
      _cloudinaryVideoUrls[index] = url;
      _isUploadingVideo[index] = false;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _cloudinaryImageUrls[index] = null;
      _isUploadingImage[index] = false;
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _cloudinaryVideoUrls[index] = null;
      _isUploadingVideo[index] = false;
    });
  }

  bool _validateForm() {
    final imagesCount =
        _cloudinaryImageUrls.whereType<String>().where((e) => e.isNotEmpty).length;
    if (imagesCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une photo principale')),
      );
      return false;
    }
    if (_isAnyUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.waitUploadFinish)),
      );
      return false;
    }
    if (_marqueController.text.trim().isEmpty ||
        _modeleController.text.trim().isEmpty ||
        _selectedTypeMoto == null ||
        _anneeController.text.trim().isEmpty ||
        _cylindreeController.text.trim().isEmpty ||
        _prixController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillRequiredFields)),
      );
      return false;
    }
    if (_equipementsSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cochez au moins un équipement')),
      );
      return false;
    }
    return true;
  }

  Future<void> _onValidate() async {
    if (!_validateForm()) return;

    final images =
        _cloudinaryImageUrls.whereType<String>().where((e) => e.isNotEmpty).toList();
    final videos =
        _cloudinaryVideoUrls.whereType<String>().where((e) => e.isNotEmpty).toList();

    final lieu = _effectiveLieu;
    final marque = _marqueController.text.trim();
    final modele = _modeleController.text.trim();
    final titre = '$marque $modele'.trim();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MotoInfo(
          titre: titre,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : 'Moto neuve — $marque $modele',
          marque: marque,
          modele: modele,
          annee: _anneeController.text.trim(),
          prix: _prixController.text.trim(),
          condition: 'Nouveau',
          cylindre: _cylindreeController.text.trim(),
          lieu: lieu,
          fournisseur: _fournisseurPayload,
          images: images,
          videos: videos,
          video: videos.isNotEmpty ? videos.first : null,
          entreprise: _entreprise,
          typeMoto: _selectedTypeMoto,
          typeMoteur: _selectedTypeMoteur,
          puissance: _puissanceController.text.trim(),
          transmission: _selectedTransmission,
          demarrage: _selectedDemarrage,
          refroidissement: _selectedRefroidissement,
          capaciteReservoir: _capaciteReservoirController.text.trim(),
          autonomie: _autonomieController.text.trim(),
          disponibilite: _selectedDisponibilite,
          garantieConstructeur: _garantieConstructeur,
          dureeGarantie: _garantieConstructeur ? _dureeGarantieLabel : '',
          equipements: _equipementsSelectionnes.toList(),
          devise: _selectedDevise,
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = true}) {
    return Text(
      required ? '$text *' : text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget _buildFieldRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildGarantieStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _garantieMoisIndex > 0
                ? () => setState(() => _garantieMoisIndex--)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            _dureeGarantieLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: _garantieMoisIndex < _garantieMoisOptions.length - 1
                ? () => setState(() => _garantieMoisIndex++)
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceWithDevise() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Prix'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _prixController,
                hint: l10n.priceFcfaExample,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: decimalOptionalInputFormatters,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 88,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Devise', required: false),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedDevise,
                hint: 'XOF',
                items: _devises,
                onChanged: (v) =>
                    setState(() => _selectedDevise = v ?? 'XOF'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickMultipleImages,
                icon: const Icon(Icons.add_photo_alternate, size: 20),
                label: Text(l10n.addImages),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8BF13),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_maxMediaSlots, (index) {
            final url = _cloudinaryImageUrls[index];
            final uploading = _isUploadingImage[index];
            if ((url == null || url.isEmpty) && !uploading) {
              return const SizedBox.shrink();
            }
            return Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF8BF13)),
                    image: url != null && url.isNotEmpty
                        ? DecorationImage(
                            image: tranooImageProvider(
                              url,
                              cloudinaryWidthPx: cloudinaryWidthPx(
                                context,
                                logicalWidth: 80,
                              ),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[200],
                  ),
                  child: uploading
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                if (url != null && url.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _videoPageController,
        itemCount: _maxVideoSlots,
        onPageChanged: (i) => setState(() => _currentVideoIndex = i),
        itemBuilder: (context, index) {
          final url = _cloudinaryVideoUrls[index];
          final uploading = _isUploadingVideo[index];
          return GestureDetector(
            onTap: url != null
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Movie(videoUrl: url),
                      ),
                    )
                : () => _pickVideo(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: url != null ? Colors.green : Colors.blue,
                ),
              ),
              child: Center(
                child: uploading
                    ? const CircularProgressIndicator()
                    : Icon(
                        url != null ? Icons.play_circle_fill : Icons.videocam,
                        size: 48,
                        color: url != null ? Colors.green : Colors.blue,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquipementsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _equipementsOptions.map((opt) {
        final selected = _equipementsSelectionnes.contains(opt);
        return FilterChip(
          label: Text(opt),
          selected: selected,
          selectedColor: const Color(0xFFF8BF13).withOpacity(0.4),
          onSelected: (v) {
            setState(() {
              if (v) {
                _equipementsSelectionnes.add(opt);
              } else {
                _equipementsSelectionnes.remove(opt);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildProfileFournisseurSummary() {
    if (_loadingPhone) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Chargement du profil...', style: TextStyle(color: Colors.black54)),
      );
    }
    final hasLoc =
        _fournisseurLatitude != null && _fournisseurLongitude != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _fournisseurTelController.text.isNotEmpty
                ? 'Tél. ${_fournisseurTelController.text}'
                : 'Téléphone non renseigné — complétez votre profil',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _fournisseurTelController.text.isNotEmpty
                  ? Colors.black87
                  : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          if (hasLoc)
            Text(
              _fournisseurAddress.isNotEmpty
                  ? truncateWithEllipsis(_fournisseurAddress)
                  : 'Position GPS enregistrée',
              style: const TextStyle(fontSize: 13),
            )
          else
            const Text(
              'Localisation manquante — mettez à jour votre position dans le profil.',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moto neuve'),
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Photo principale'),
                    const SizedBox(height: 8),
                    _buildImageSection(),
                    const SizedBox(height: 16),
                    _buildLabel('Vidéos (optionnel)', required: false),
                    const SizedBox(height: 8),
                    _buildVideoSection(),
                    const SizedBox(height: 24),

                    _buildFieldRow(
                      left: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Marque'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _marqueController,
                            hint: 'Ex. Yamaha',
                          ),
                        ],
                      ),
                      right: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Modèle'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _modeleController,
                            hint: 'Ex. NMAX',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldRow(
                      left: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Type de moto'),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedTypeMoto,
                            hint: 'Sélectionner',
                            items: _typesMoto,
                            onChanged: (v) =>
                                setState(() => _selectedTypeMoto = v),
                          ),
                        ],
                      ),
                      right: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Année modèle'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _anneeController,
                            hint: 'Ex. 2024',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Cylindrée (CC)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _cylindreeController,
                      hint: 'Ex. 125',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    _buildFieldRow(
                      left: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Type de moteur', required: false),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedTypeMoteur,
                            hint: 'Sélectionner',
                            items: _typesMoteur,
                            onChanged: (v) =>
                                setState(() => _selectedTypeMoteur = v),
                          ),
                        ],
                      ),
                      right: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Puissance', required: false),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _puissanceController,
                            hint: 'Ex. 11 ch',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldRow(
                      left: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Transmission', required: false),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedTransmission,
                            hint: 'Sélectionner',
                            items: _transmissions,
                            onChanged: (v) =>
                                setState(() => _selectedTransmission = v),
                          ),
                        ],
                      ),
                      right: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Démarrage', required: false),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedDemarrage,
                            hint: 'Sélectionner',
                            items: _demarrages,
                            onChanged: (v) =>
                                setState(() => _selectedDemarrage = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFieldRow(
                      left: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Refroidissement', required: false),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedRefroidissement,
                            hint: 'Sélectionner',
                            items: _refroidissements,
                            onChanged: (v) => setState(
                              () => _selectedRefroidissement = v,
                            ),
                          ),
                        ],
                      ),
                      right: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Capacité du réservoir', required: false),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _capaciteReservoirController,
                            hint: 'Ex. 5 L',
                          ),
                        ],
                      ),
                    ),
                    if (_selectedTypeMoteur == 'Électrique') ...[
                      const SizedBox(height: 16),
                      _buildLabel('Autonomie', required: false),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _autonomieController,
                        hint: 'Ex. 80 km',
                      ),
                    ],
                    const SizedBox(height: 24),

                    _buildPriceWithDevise(),
                    const SizedBox(height: 16),
                    _buildLabel('Disponibilité', required: false),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedDisponibilite,
                      hint: 'Sélectionner',
                      items: _disponibilites,
                      onChanged: (v) =>
                          setState(() => _selectedDisponibilite = v),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Garantie constructeur'),
                      value: _garantieConstructeur,
                      activeColor: const Color(0xFFF8BF13),
                      onChanged: (v) =>
                          setState(() => _garantieConstructeur = v),
                    ),
                    if (_garantieConstructeur) ...[
                      const SizedBox(height: 8),
                      _buildLabel('Durée garantie', required: false),
                      const SizedBox(height: 8),
                      _buildGarantieStepper(),
                    ],
                    const SizedBox(height: 24),

                    _buildLabel('Description', required: false),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Décrivez votre moto (facultatif)...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Équipements'),
                    const SizedBox(height: 8),
                    _buildEquipementsSection(),
                    const SizedBox(height: 24),

                    const Text(
                      'Téléphone et localisation repris de votre inscription.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    _buildProfileFournisseurSummary(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAnyUploading ? null : _onValidate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isAnyUploading ? 'Upload en cours...' : 'Aperçu',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _anneeController.dispose();
    _cylindreeController.dispose();
    _puissanceController.dispose();
    _capaciteReservoirController.dispose();
    _autonomieController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    _localisationController.dispose();
    _fournisseurTelController.dispose();
    _videoPageController.dispose();
    super.dispose();
  }
}
