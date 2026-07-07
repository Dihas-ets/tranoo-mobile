import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:tranoo/services/cart_service.dart';
import '../../config/backend_config.dart';
import 'package:tranoo/providers/counter_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tranoo/data/screens/map_picker_screen.dart';
import 'package:tranoo/data/screens/avant_home.dart';
import 'package:tranoo/utils/payment_debug_logger.dart';
import 'package:tranoo/widgets/feexpay_v2_payment_screen.dart';
import 'package:tranoo/l10n/app_localizations.dart';

enum PaymentMethod { cash, online }

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  double _deliveryFee = 0; // Calculé automatiquement
  double _pricePerKm = 0;
  double? _deliveryDistanceKm;
  bool _isProcessing = false;
  final String _transKey = randomAlphaNumeric(15);
  
  double? _deliveryLatitude;
  double? _deliveryLongitude;

  double? _supplierLatitude;
  double? _supplierLongitude;

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * (3.141592653589793 / 180.0);
    final dLon = (lon2 - lon1) * (3.141592653589793 / 180.0);
    final la1 = lat1 * (3.141592653589793 / 180.0);
    final la2 = lat2 * (3.141592653589793 / 180.0);
    final h = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(la1) * cos(la2) * (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return r * c;
  }
  
  // États pour la sélection d'adresse
  bool _useCurrentLocation = false;
  bool _useMapSelection = false;
  bool _isLoadingLocation = false;
  bool _isLoadingMap = false;
  
  // Adresse dynamique
  String _selectedAddress = '';
  String _selectedCity = '';
  String _selectedCountry = 'Bénin';
  
  String _selectedDisponibilite = '';
  bool _disponibiliteInitialized = false;

  List<String> _disponibiliteOptions(AppLocalizations l10n) => [
        l10n.availAvailable,
        l10n.avail15to30min,
        l10n.avail1to2h,
        l10n.availBefore12,
        l10n.availBefore18,
        l10n.availBefore20,
        l10n.availFlexible,
      ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_disponibiliteInitialized) {
      _selectedDisponibilite = AppLocalizations.of(context)!.availAvailable;
      _disponibiliteInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDeliveryPricing();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveryPricing() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: getApiBaseUrl(),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final response = await dio.get('/deliveries/settings');
      final root = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final settings = root['settings'] is Map<String, dynamic>
          ? root['settings'] as Map<String, dynamic>
          : root;
      final raw = settings['pricePerKm'];
      final parsed = raw is num ? raw.toDouble() : double.tryParse('$raw');
      if (parsed != null && parsed >= 0 && mounted) {
        setState(() => _pricePerKm = parsed);
      }
      developer.log('[ORDER_SUMMARY] pricePerKm loaded=$_pricePerKm');
    } catch (e) {
      developer.log('[ORDER_SUMMARY] pricePerKm load error=$e');
    }
  }

  Future<void> _loadSupplierCoordsIfNeeded(CartService cart) async {
    if (_supplierLatitude != null && _supplierLongitude != null) return;
    if (cart.items.isEmpty) return;

    final firstItem = cart.items.first;
    if (firstItem.supplierLatitude != null && firstItem.supplierLongitude != null) {
      _supplierLatitude = firstItem.supplierLatitude?.toDouble();
      _supplierLongitude = firstItem.supplierLongitude?.toDouble();
      developer.log(
        '[ORDER_SUMMARY] supplier coords from cart=($_supplierLatitude,$_supplierLongitude)',
      );
      return;
    }

    final articleId = firstItem.articleId;
    if (articleId.isEmpty) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: getApiBaseUrl(),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      final response = await dio.get('/articles/$articleId');
      final root = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final article = root['article'] is Map<String, dynamic>
          ? root['article'] as Map<String, dynamic>
          : root;
      final fournisseur = article['fournisseur'] is Map<String, dynamic>
          ? article['fournisseur'] as Map<String, dynamic>
          : <String, dynamic>{};
      final lat = fournisseur['latitude'];
      final lng = fournisseur['longitude'];
      final parsedLat = lat is num ? lat.toDouble() : double.tryParse('$lat');
      final parsedLng = lng is num ? lng.toDouble() : double.tryParse('$lng');
      if (parsedLat != null && parsedLng != null) {
        _supplierLatitude = parsedLat;
        _supplierLongitude = parsedLng;
      }
      developer.log(
        '[ORDER_SUMMARY] supplier coords from article=($_supplierLatitude,$_supplierLongitude)',
      );
    } catch (e) {
      developer.log('[ORDER_SUMMARY] supplier coords load error=$e');
    }
  }

  // Méthode pour obtenir la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage(AppLocalizations.of(context)!.locationPermissionDenied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(AppLocalizations.of(context)!.enableLocationInSettingsMsg);
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Obtenir l'adresse dynamique via reverse geocoding
      String address = await _getAddressFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _deliveryLatitude = position.latitude;
        _deliveryLongitude = position.longitude;
        _useCurrentLocation = true;
        _useMapSelection = false;
        _selectedAddress = address;
        _addressController.text = address.isNotEmpty
            ? address
            : AppLocalizations.of(context)!.positionCoords(
                position.latitude.toStringAsFixed(6),
                position.longitude.toStringAsFixed(6),
              );
        _isLoadingLocation = false;
      });

      // Calculer automatiquement les frais de livraison
      await _calculateDeliveryFeeFromLocation();

      _showMessage(AppLocalizations.of(context)!.locationRetrievedSuccess);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      _showMessage(
          AppLocalizations.of(context)!.locationError(e.toString()));
    }
  }

  // Méthode pour obtenir l'adresse depuis les coordonnées (reverse geocoding)
  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Utiliser une API de reverse geocoding gratuite (Nominatim OSM)
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'TranooApp/1.0',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final address = data['display_name'] as String? ?? '';
        final city = data['address']?['city'] ?? data['address']?['town'] ?? data['address']?['village'] ?? '';
        
        setState(() {
          _selectedCity = city;
        });
        
        return address;
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
    
    return '';
  }

  // Méthode pour ouvrir la carte de sélection
  Future<void> _openMapSelection() async {
    setState(() {
      _isLoadingMap = true;
    });
    
    try {
      developer.log('=== OUVERTURE CARTE SÉLECTION ===');
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPickerScreen(
            initialLatitude: _deliveryLatitude,
            initialLongitude: _deliveryLongitude,
          ),
        ),
      );
      
      developer.log('Résultat carte: $result');
      developer.log('Type de résultat: ${result.runtimeType}');

      if (result != null && result is Map<String, dynamic>) {
        final selectedLat = (result['latitude'] as num?)?.toDouble();
        final selectedLng = (result['longitude'] as num?)?.toDouble();
        if (selectedLat == null || selectedLng == null) {
          setState(() {
            _isLoadingMap = false;
          });
          _showMessage(AppLocalizations.of(context)!.invalidCoordinates);
          return;
        }
        
        developer.log('Coordonnées sélectionnées: Lat=$selectedLat, Lng=$selectedLng');
        
        // Obtenir l'adresse dynamique pour la position sélectionnée
        String address = await _getAddressFromCoordinates(selectedLat, selectedLng);
        
        developer.log('Adresse récupérée: $address');

        setState(() {
          _deliveryLatitude = selectedLat;
          _deliveryLongitude = selectedLng;
          _useMapSelection = true;
          _useCurrentLocation = false;
          _selectedAddress = address;
          _addressController.text = address.isNotEmpty
              ? address
              : AppLocalizations.of(context)!.positionCoords(
                  selectedLat.toStringAsFixed(6),
                  selectedLng.toStringAsFixed(6),
                );
          _isLoadingMap = false;
        });
        
        // Calculer automatiquement les frais de livraison
        await _calculateDeliveryFeeFromLocation();
        
        _showMessage(AppLocalizations.of(context)!.deliveryAddressSelectedOnMap);
        developer.log('✅ SÉLECTION CARTE RÉUSSIE - Lat: $selectedLat, Lng: $selectedLng, Adresse: $address');
      } else {
        developer.log('❌ SÉLECTION CARTE ANNULÉE - Résultat: $result');
        setState(() {
          _isLoadingMap = false;
        });
        _showMessage(AppLocalizations.of(context)!.selectionCancelled);
      }
    } catch (e) {
      developer.log('❌ ERREUR SÉLECTION CARTE: $e');
      setState(() {
        _isLoadingMap = false;
      });
      _showMessage(
          AppLocalizations.of(context)!.mapSelectionError(e.toString()));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF8BF13),
        duration: const Duration(seconds: 3),
      ),
    );
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

  Future<void> _calculateDeliveryFeeFromLocation() async {
    if (_deliveryLatitude != null && _deliveryLongitude != null) {
      try {
        final cart = Provider.of<CartService>(context, listen: false);
        await _loadDeliveryPricing();
        await _loadSupplierCoordsIfNeeded(cart);

        // Coordonnées fournisseur depuis les articles (priorité) sinon arrêt (pas de fallback magique).
        final supplierLat = _supplierLatitude;
        final supplierLng = _supplierLongitude;
        if (supplierLat == null || supplierLng == null) {
          if (mounted) {
            setState(() {
              _deliveryFee = 0;
              _deliveryDistanceKm = null;
            });
          }
          _showMessage(AppLocalizations.of(context)!.supplierCoordsUnavailable);
          developer.log('[ORDER_SUMMARY] calc skipped: missing supplier coords');
          return;
        }

        // Fallback local (si API indisponible): utiliser le tarif/km admin.
        final km = _haversineKm(
          supplierLat,
          supplierLng,
          _deliveryLatitude!,
          _deliveryLongitude!,
        );
        final billedKm = km > 0 && km < 1 ? 1.0 : km;
        final localFee = (billedKm * _pricePerKm)
            .round()
            .clamp(0, 1000000000)
            .toDouble();
        developer.log(
          '[ORDER_SUMMARY] local calc supplier=($supplierLat,$supplierLng) delivery=($_deliveryLatitude,$_deliveryLongitude) km=$km pricePerKm=$_pricePerKm localFee=$localFee',
        );
        
        final response = await Dio().post(
          '${getApiBaseUrl()}/delivery-zones/calculate-fee',
          data: {
            'supplier_lat': supplierLat,
            'supplier_lng': supplierLng,
            'delivery_lat': _deliveryLatitude,
            'delivery_lng': _deliveryLongitude,
          },
        );
        
        if (response.statusCode == 200) {
          // backend: { deliveryFee } (camelCase) — tolère anciennes clés
          final backendFee = (response.data['deliveryFee'] as num?)?.toDouble() ??
              (response.data['delivery_fee'] as num?)?.toDouble() ??
              localFee;
          final fee = (km > 0 && backendFee < _pricePerKm)
              ? _pricePerKm
              : backendFee;
          final backendPricePerKm =
              (response.data['pricePerKm'] as num?)?.toDouble() ??
              (response.data['zoneInfo'] is Map
                  ? (response.data['zoneInfo']['pricePerKm'] as num?)?.toDouble()
                  : null);
          setState(() {
            _deliveryFee = fee;
            if (backendPricePerKm != null && backendPricePerKm >= 0) {
              _pricePerKm = backendPricePerKm;
            }
          });
          developer.log(
            '[ORDER_SUMMARY] backend calc ok fee=$_deliveryFee pricePerKm=$_pricePerKm',
          );
        } else {
          setState(() {
            _deliveryFee = localFee;
          });
          developer.log('[ORDER_SUMMARY] backend non-200 => localFee=$_deliveryFee');
        }
      } catch (e) {
        developer.log('[ORDER_SUMMARY] Error calculating delivery fee: $e');
        // Fallback local (tarif/km admin récupéré)
        final supplierLat = _supplierLatitude;
        final supplierLng = _supplierLongitude;
        if (supplierLat == null || supplierLng == null) {
          if (mounted) {
            setState(() => _deliveryFee = 0);
          }
          return;
        }
        final km = _haversineKm(
          supplierLat,
          supplierLng,
          _deliveryLatitude!,
          _deliveryLongitude!,
        );
        final billedKm = km > 0 && km < 1 ? 1.0 : km;
        if (mounted) {
          setState(() => _deliveryFee = (billedKm * _pricePerKm).round().toDouble());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderSummary),
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

                      // Section Adresse de livraison avec 2 boutons
                      Text(
                        l10n.deliveryAddress,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      
                      // Bouton 1: Récupérer position actuelle
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoadingLocation || _isLoadingMap ? null : _getCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo clair
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoadingLocation
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.fetchingLocation,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.my_location, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.fetchMyLocation,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Bouton 2: Choisir sur la carte
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoadingLocation || _isLoadingMap ? null : _openMapSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6A800), // Jaune Tranoo foncé
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoadingMap
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.loading,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.map, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.chooseOnMap,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Affichage de l'adresse sélectionnée
                      if (_useCurrentLocation || _useMapSelection)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8BF13).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF8BF13)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _useCurrentLocation ? Icons.my_location : Icons.map,
                                    color: const Color(0xFFF8BF13),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _useCurrentLocation
                                        ? l10n.currentPositionLabel
                                        : l10n.selectedPositionLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF8BF13),
                                    ),
                                  ),
                                  if (_selectedCity.isNotEmpty) ...[
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8BF13),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _selectedCity,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedAddress.isNotEmpty 
                                          ? _selectedAddress 
                                          : _addressController.text,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (_deliveryLatitude != null && _deliveryLongitude != null)
                                    GestureDetector(
                                      onTap: () {
                                        _showMessage('Coordonnées: ${_deliveryLatitude!.toStringAsFixed(6)}, ${_deliveryLongitude!.toStringAsFixed(6)}');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),
                      
                      // Section Disponibilité
                      Text(
                        l10n.availability,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _disponibiliteOptions(l10n).contains(_selectedDisponibilite) ? _selectedDisponibilite : _disponibiliteOptions(l10n).first,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDisponibilite = newValue!;
                            });
                          },
                          items: _disponibiliteOptions(l10n).map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            );
                          }).toList(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                          isExpanded: true,
                        ),
                      ),

                      const SizedBox(height: 8),
                      // Total de la commande
                      Text(
                        l10n.orderTotalLabel,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _rowKV(l10n.subtotal, '${subtotal.toStringAsFixed(0)} F'),
                      const SizedBox(height: 6),
                      _rowKV(
                        l10n.deliveryFeeLabel,
                        '${_deliveryFee.toStringAsFixed(0)} F',
                      ),
                      const Divider(height: 24),
                      _rowKV(l10n.total, '${total.toStringAsFixed(0)} F', isBold: true),

                      // Bouton de confirmation intégré dans la page
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (cart.items.isEmpty || _isProcessing || (!_useCurrentLocation && !_useMapSelection))
                              ? null
                              : () async {
                                  // Confirmer la commande
                                  final confirmed = await _confirmOrder(total);
                                  if (confirmed && mounted) {
                                    developer.log('ÉTAPE Paiement: ouverture FeexPay v2...');
                                    final paymentResult = await openFeexPayV2Payment(
                                      context,
                                      amount: total,
                                      description: l10n.orderPaymentTranooDescription,
                                      customId: _transKey,
                                      paymentType: 'achat',
                                    );
                                    final paid = paymentResult?.success == true;
                                    developer.log(
                                      'ÉTAPE Paiement: résultat success=$paid tx=${paymentResult?.transactionId}',
                                    );
                                    if (!paid) {
                                      PaymentDebugLogger.blocked(
                                        'ORDER_CART',
                                        'Paiement panier non confirmé',
                                        paymentResult?.errorMessage,
                                      );
                                      _showMessage(
                                        l10n.transactionFailedNotSaved,
                                      );
                                      return;
                                    }
                                    await _processOrder(total, cart);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isProcessing
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      l10n.processingOrder,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  l10n.checkout,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      
                      // Espacement pour éviter que le contenu ne soit caché par le bas
                      const SizedBox(height: 20),
                    ],
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
        title: Text(l10n.selectAddress),
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
            child: Text(l10n.cancel),
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
    final l10n = AppLocalizations.of(context)!;
    developer.log('=== DÉBUT VALIDATION COMMANDE ===');
    developer.log('Total: $total');
    
    // Vérifier si tous les champs obligatoires sont remplis
    final address = _selectedAddress.isNotEmpty ? _selectedAddress : _addressController.text.trim();
    final city = _selectedCity;
    final country = _selectedCountry;
    
    developer.log('Adresse: $address');
    developer.log('Ville: $city');
    developer.log('Pays: $country');
    
    // Vérifier si une adresse a été sélectionnée (GPS ou carte)
    if (!_useCurrentLocation && !_useMapSelection) {
      _showMessage(AppLocalizations.of(context)!.selectDeliveryAddressPlease);
      return false;
    }
    
    if (address.isEmpty) {
      _showMessage(AppLocalizations.of(context)!.invalidDeliveryAddress);
      return false;
    }

    developer.log('✅ VALIDATION RÉUSSIE - Adresse sélectionnée');

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
                    color: const Color(0xFFF8BF13).withOpacity(0.2), // Jaune Tranoo transparent
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFFF8BF13), // Jaune Tranoo
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.confirmYourOrder,
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
                  l10n.totalToPay(total.toStringAsFixed(0)),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${l10n.deliveryAddress}:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedAddress.isNotEmpty ? _selectedAddress : _addressController.text.trim(),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo
                        foregroundColor: Colors.black,
                      ),
                      child: Text(l10n.confirm),
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
      
      // Paiement validé avant création commande (via FeexPay v2)
      // On garde paymentMethod online.
      const paymentMethodStr = 'online';
      developer.log('Méthode de paiement: $paymentMethodStr (paiement validé)');
      
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
        
        developer.log('ÉTAPE 4: Affichage popup succès commande...');
        await _showSuccessModal();
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
            content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
      throw Exception(AppLocalizations.of(context)!.errorUserNotConnected);
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
          _supplierLatitude = firstItem.supplierLatitude?.toDouble();
          _supplierLongitude = firstItem.supplierLongitude?.toDouble();
          lieuDepart = {
            'nom': firstItem.supplierName ?? AppLocalizations.of(context)!.supplierDefault,
            'adresse': firstItem.supplierName ?? AppLocalizations.of(context)!.supplierAddressDefault,
            'latitude': firstItem.supplierLatitude,
            'longitude': firstItem.supplierLongitude,
          };
        }
      }

      // Ne plus injecter un faux fallback Cotonou: garder null si inconnu.

      final orderData = {
        'items': itemsData,
        'subtotal': cart.subtotal,
        'deliveryFee': _deliveryFee,
        'total': total,
        'paymentMethod': paymentMethod,
        'deliveryAddress': _selectedAddress.isNotEmpty ? _selectedAddress : _addressController.text.trim(),
        'deliveryNote': _noteController.text.trim(),
        'disponibilite': _selectedDisponibilite, // Ajout du champ Disponibilité
        'status': 'pending', // Toujours 'pending' car le paiement se fait après réception
        'isDeliveryRequired': true,
        'deliveryInfo': {
          'lieuDepart': lieuDepart,
          'lieuDestination': {
            'adresse': _selectedAddress.isNotEmpty ? _selectedAddress : _addressController.text.trim(),
            'latitude': _deliveryLatitude,
            'longitude': _deliveryLongitude,
            'ville': _selectedCity,
            'pays': _selectedCountry,
          }
        },
        'trackingInfo': {
          'disponibilite': _selectedDisponibilite,
        },
        'conditionsAffichee': true,
        'paymentConfirmed': true,
      };

      developer.log('Données commande préparées - ${orderData.keys.length} champs');
      developer.log('URL de la requête: $baseUrl/orders');
      developer.log('Adresse livraison: ${orderData['deliveryAddress']}');
      developer.log('Coordonnées: (${_deliveryLatitude}, ${_deliveryLongitude})');
      developer.log('Disponibilité: ${orderData['disponibilite']}'); // Log du champ Disponibilité
      
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
            Text(
              AppLocalizations.of(context)!.orderConfirmedTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.orderSavedSuccess,
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
                      Text(
                        AppLocalizations.of(context)!.deliveryExpected,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.deliveryBetween3And7Days,
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
                      Text(
                        AppLocalizations.of(context)!.youWillReceiveNotification,
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
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(this.context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AvantHome()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.returnHome,
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
        return (response.data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      } else {
        throw Exception('Failed to calculate delivery fee');
      }
    } catch (e) {
      debugPrint('Error calculating delivery fee: $e');
      return 0.0;
    }
  }
}
