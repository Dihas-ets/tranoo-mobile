import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'mastervacpage.dart'; // Importez la page MastervacPage
import '../../utils/cloudinary_upload.dart';
import 'package:tranoo/services/user_service.dart';
import 'dart:developer';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';

class CreateSellPage2 extends StatefulWidget {
  const CreateSellPage2({super.key});

  @override
  CreateSellPage2State createState() => CreateSellPage2State();
}

class CreateSellPage2State extends State<CreateSellPage2> {
  static const int _maxMediaSlots = 12;
  static const String _conditionNew = 'Nouveau';
  static const String _conditionUsed = 'Occasion';
  static const String _otherOption = 'Autre';
  static const String _noEngine = 'Aucun';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _anneeController = TextEditingController();
  final TextEditingController _fournisseurTelController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _localisationController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String? _selectedPieceType; // Nouveau/Occasion
  String? _selectedFuelType; // Essence/Gazoil/Diezel/Electrique/Hybride
  String? _selectedModel; // Modèle (String, pas int)
  // Variables pour l'upload d'images
  List<File?> _uploadedImages =
      List<File?>.filled(_maxMediaSlots, null, growable: false);
  List<String?> _cloudinaryUrls =
      List<String?>.filled(_maxMediaSlots, null, growable: false);
  List<bool> _isUploadingImage =
      List<bool>.filled(_maxMediaSlots, false, growable: false);

  // Variables pour l'upload de vidéo
  String? _cloudinaryVideoUrl;
  bool _isUploadingVideo = false;
  double _videoUploadProgress = 0.0; // Progression de l'upload vidéo

  bool get _isAnyUploading =>
      _isUploadingImage.contains(true) || _isUploadingVideo;

  final List<String> _pieceTypes = [_conditionNew, _conditionUsed];
  final List<String> _fuelTypes = [
    'Essence',
    'Gazoil',
    'Diezel',
    'Electrique',
    'Hybride',
    _noEngine,
  ];
  final List<String> _models = ['Modèle1', 'Modèle2', _otherOption];

  String _conditionLabel(AppLocalizations l10n, String value) {
    if (value == _conditionNew) return l10n.newCondition;
    if (value == _conditionUsed) return l10n.usedCondition;
    return value;
  }

  String _fuelLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'Essence':
        return l10n.petrol;
      case 'Gazoil':
        return l10n.gazoil;
      case 'Diezel':
        return l10n.diesel;
      case 'Electrique':
        return l10n.electric;
      case 'Hybride':
        return l10n.hybrid;
      case _noEngine:
        return l10n.noEngine;
      default:
        return value;
    }
  }
  String? _customFuelType;
  String? _customModel;

  Future<void> _takePhotoFromCamera() async {
    final emptyIndex = _cloudinaryUrls.indexWhere((u) => u == null);
    if (emptyIndex == -1) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.maxImagesReached)),
        );
      }
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    await _uploadImageAt(emptyIndex, File(image.path));
  }

  Future<void> _uploadImageAt(int index, File file) async {
    setState(() {
      _uploadedImages[index] = file;
      _isUploadingImage[index] = true;
    });
    try {
      final url = await uploadImageToCloudinary(
        file,
        folder: CloudinaryFolders.pieceImages,
      );
      if (!mounted) return;
      if (url != null) {
        setState(() => _cloudinaryUrls[index] = url);
      } else {
        setState(() => _uploadedImages[index] = null);
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.uploadFailed(e.toString()))),
      );
      setState(() => _uploadedImages[index] = null);
    } finally {
      if (!mounted) return;
      setState(() => _isUploadingImage[index] = false);
    }
  }

  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    await _uploadImageAt(index, File(image.path));
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages[index] = null;
      _cloudinaryUrls[index] = null;
      _isUploadingImage[index] = false;
    });
  }

  void _removeVideo() {
    setState(() {
      _cloudinaryVideoUrl = null;
      _isUploadingVideo = false;
    });
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video =
        await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

      setState(() {
        _isUploadingVideo = true;
        _videoUploadProgress = 0.0;
      });

    try {
      final url = await uploadVideoToCloudinary(
        File(video.path),
        folder: CloudinaryFolders.pieceVideos,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _videoUploadProgress = progress;
          });
        },
      );
      if (!mounted) return;
      if (url != null) {
        setState(() {
          _cloudinaryVideoUrl = url;
        });
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.videoUploadError)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.videoUploadFailed(e.toString()))),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploadingVideo = false;
        _videoUploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 800;
    final isLargeScreen = screenWidth >= 800;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    // Titre
                    _buildLabel(
                      l10n.pieceName,
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: l10n.pieceName,
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
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Type et Année
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                l10n.typeLabel,
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              // Utilisation de MediaQuery pour détecter la taille de l'écran
                              Builder(
                                builder: (context) {
                                  // Récupération de la largeur de l'écran
                                  final screenWidth =
                                      MediaQuery.of(context).size.width;

                                  // Si l'écran est petit (moins de 400px), on utilise Wrap
                                  // Sinon, on utilise Row pour une meilleure performance
                                  if (screenWidth < 400) {
                                    return Wrap(
                                      spacing:
                                          8, // Espacement horizontal entre les éléments
                                      children:
                                          _pieceTypes.map((type) {
                                            return Row(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min, // Réduit la taille au minimum nécessaire
                                              children: [
                                                Radio<String>(
                                                  value: type,
                                                  groupValue:
                                                      _selectedPieceType,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedPieceType =
                                                          value;
                                                    });
                                                  },
                                                  activeColor: Colors.amber,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap, // Réduit la zone de toucher
                                                ),
                                                Text(
                                                  _conditionLabel(l10n, type),
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen
                                                            ? 14
                                                            : isMediumScreen
                                                            ? 16
                                                            : 18,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    );
                                  } else {
                                    // Pour les grands écrans, on utilise Row
                                    return Row(
                                      children:
                                          _pieceTypes.map((type) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 16,
                                              ), // Espacement entre les radio buttons
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Radio<String>(
                                                    value: type,
                                                    groupValue:
                                                        _selectedPieceType,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedPieceType =
                                                            value;
                                                      });
                                                    },
                                                    activeColor: Colors.amber,
                                                  ),
                                                  Text(
                                                    _conditionLabel(l10n, type),
                                                    style: TextStyle(
                                                      fontSize:
                                                          isSmallScreen
                                                              ? 14
                                                              : isMediumScreen
                                                              ? 16
                                                              : 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                l10n.year,
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _anneeController,
                                decoration: InputDecoration(
                                  hintText: l10n.enterYearShort,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Type et Modèle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                l10n.engineType,
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: _selectedFuelType,
                                hint: l10n.engineType,
                                items: _fuelTypes,
                                itemLabel: (v) => _fuelLabel(l10n, v),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFuelType = value;
                                    if (value != _noEngine) {
                                      _customFuelType = null;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_selectedFuelType == _noEngine)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: l10n.enterEngineType,
                                filled: true,
                                fillColor: Color(0xFFF2F2F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _customFuelType = val;
                                });
                              },
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                l10n.model,
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: _selectedModel,
                                hint: l10n.model,
                                items: _models,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedModel = value;
                                    _customModel =
                                        value == _otherOption ? '' : null;
                                  });
                                },
                              ),
                              if (_selectedModel == _otherOption)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: l10n.enterModel,
                                      filled: true,
                                      fillColor: Color(0xFFF2F2F2),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _customModel = val;
                                      });
                                    },
                                  ),
                                ),
                              if (_selectedModel != null &&
                                  _selectedModel != _otherOption)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    l10n.selectedModelLabel(_selectedModel!),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              if (_selectedModel == _otherOption &&
                                  _customModel != null &&
                                  _customModel!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    l10n.customModelLabel(_customModel!),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildLabel(
                      l10n.characteristics.replaceAll(':', ''),
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                      isRequired: false,
                    ),
                    const SizedBox(height: 24),

                    // Emplacement et Prix
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                l10n.placement,
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _localisationController,
                                decoration: InputDecoration(
                                  hintText: l10n.defaultLocation,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                l10n.price,
                                isSmallScreen,
                                isMediumScreen,
                                isLargeScreen,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _prixController,
                                decoration: InputDecoration(
                                  hintText: l10n.enterPrice,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    _buildLabel(
                      l10n.description,
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: l10n.enterPartDescription,
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
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nom de l'entreprise
                    _buildLabel(
                      l10n.companyBlOwner,
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        hintText: l10n.enterCompanyName,
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
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel(
                      l10n.imagesOptionalMax12,
                      isSmallScreen,
                      isMediumScreen,
                      isLargeScreen,
                      isRequired: false,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final idx = _cloudinaryUrls.indexWhere((u) => u == null);
                              if (idx != -1) _pickImage(idx);
                            },
                            icon: const Icon(Icons.add_photo_alternate, size: 20),
                            label: Text(l10n.addImagesButton),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF8BF13),
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.takePhoto,
                          onPressed: _takePhotoFromCamera,
                          icon: const Icon(Icons.photo_camera),
                          color: const Color(0xFFF8BF13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 2 : 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _maxMediaSlots,
                      itemBuilder: (context, index) {
                        final file = _uploadedImages[index];
                        final uploadedUrl = _cloudinaryUrls[index];
                        final hasMedia = file != null || uploadedUrl != null;
                        return GestureDetector(
                          onTap: () => _pickImage(index),
                          child: Container(
                        decoration: BoxDecoration(
                              color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber),
                                  ),
                        child: Stack(
                              alignment: Alignment.center,
                          children: [
                                if (uploadedUrl != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: TranooNetworkImage(
                                      url: uploadedUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      cloudinaryWidthPx: cloudinaryWidthPx(
                                        context,
                                      ),
                                    ),
                                  )
                                else if (file != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                else
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                        size: 30,
                                  ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                                if (_isUploadingImage[index])
                                  const Positioned.fill(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                                if (hasMedia)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                        if (uploadedUrl != null)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                          onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                          ),
                        );
                      },
                      ),
                    const SizedBox(height: 16),
                    // Upload vidéo avec aperçu
                    _buildVideoUploadSection(
                      l10n: l10n,
                      isSmallScreen: isSmallScreen,
                      isMediumScreen: isMediumScreen,
                      isLargeScreen: isLargeScreen,
                    ),
              const SizedBox(height: 20),
              _buildVerificationButton(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(
    String text,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen, {
    bool isRequired = true,
  }) {
    return Text(
      isRequired ? '$text *' : text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize:
            isSmallScreen
                ? 14
                : isMediumScreen
                ? 16
                : 18,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    String Function(String)? itemLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(itemLabel != null ? itemLabel(item) : item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildVideoUploadSection({
    required AppLocalizations l10n,
    required bool isSmallScreen,
    required bool isMediumScreen,
    required bool isLargeScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          l10n.videoOptional,
          isSmallScreen,
          isMediumScreen,
          isLargeScreen,
          isRequired: false,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _cloudinaryVideoUrl == null ? _pickVideo : null,
          child: Container(
            height: 120,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _cloudinaryVideoUrl == null ? Colors.blue : Colors.green,
                width: 2,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (_cloudinaryVideoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.videoUploadedLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.video_call,
                          color: Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addVideo,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (_isUploadingVideo)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                value: _videoUploadProgress > 0 ? _videoUploadProgress : null,
                                color: Colors.blue,
                                backgroundColor: Colors.white24,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _videoUploadProgress < 0.85
                                  ? l10n.sending
                                  : l10n.processing,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${(_videoUploadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Barre de progression linéaire
                            Container(
                              width: 160,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _videoUploadProgress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_cloudinaryVideoUrl != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: _removeVideo,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationButton(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAnyUploading ? null : _onValidate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _isAnyUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.uploadInProgress,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Text(
                l10n.verificationAction,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
      ),
    );
  }

  void _onValidate() {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();
    final annee = _anneeController.text.trim();
    final localisation = _localisationController.text.trim();
    final prix = _prixController.text.trim();
    final description = _descriptionController.text.trim();
    final company = _companyController.text.trim();
    final pieceType = _selectedPieceType;
    final fuelType = _selectedFuelType == _noEngine
        ? _customFuelType
        : _selectedFuelType;
    final model =
        (_selectedModel == _otherOption) ? _customModel : _selectedModel;
    log('[DEBUG] title: "$title" (empty: ${title.isEmpty})');
    log('[DEBUG] pieceType: "$pieceType" (null: ${pieceType == null})');
    log('[DEBUG] annee: "$annee" (empty: ${annee.isEmpty})');
    log(
      '[DEBUG] fuelType: "$fuelType" (null/empty:  ${fuelType == null || fuelType.isEmpty})',
    );
    log(
      '[DEBUG] model: "$model" (null/empty: ${model == null || model.isEmpty})',
    );
    log(
      '[DEBUG] localisation: "$localisation" (empty: ${localisation.isEmpty})',
    );
    log('[DEBUG] prix: "$prix" (empty: ${prix.isEmpty})');
    log('[DEBUG] description: "$description" (empty: ${description.isEmpty})');
    log('[DEBUG] company: "$company" (empty: ${company.isEmpty})');

    if (title.isEmpty ||
        pieceType == null ||
        annee.isEmpty ||
        (fuelType == null || fuelType.isEmpty) ||
        (model == null || model.isEmpty) ||
        localisation.isEmpty ||
        prix.isEmpty ||
        description.isEmpty ||
        company.isEmpty) {
      log('[DEBUG] Validation échouée, un ou plusieurs champs sont invalides.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillRequiredFields)),
      );
      return;
    }

    final imagesCount = _cloudinaryUrls.whereType<String>().where((url) => url.isNotEmpty).length;
    final hasImages = imagesCount > 0;
    final hasVideo = _cloudinaryVideoUrl != null && _cloudinaryVideoUrl!.isNotEmpty;
    if (!hasImages && !hasVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addAtLeastOneMedia)),
      );
      return;
    }
    
    log('[DEBUG] Validation OK, navigation vers MastervacPage.');
    final userService = UserService();
    final isAcheteur = userService.isAcheteur;
    final images = _cloudinaryUrls
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MastervacPage(
              isAcheteur: isAcheteur,
              title: title,
              year: annee,
              description: description,
              company: company,
              location: localisation,
              price: prix,
              fuelType: fuelType,
              model: model,
              pieceType: pieceType,
              images: images,
              video: _cloudinaryVideoUrl,
            ),
      ),
    );
  }
}
