import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/backend_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/in_app_delivery_popup.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/order_status_l10n.dart';

class OrderTrackingPageModern extends StatefulWidget {
  final String orderId;
  final bool showAppBar;

  const OrderTrackingPageModern({
    super.key,
    required this.orderId,
    this.showAppBar = true, // Par défaut, affiche l'AppBar (page complète)
  });

  @override
  State<OrderTrackingPageModern> createState() => _OrderTrackingPageModernState();
}

class _OrderTrackingPageModernState extends State<OrderTrackingPageModern> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _orderData;
  Map<String, dynamic>? _deliveryData;
  Timer? _locationUpdateTimer;
  Timer? _driverAnimationTimer;
  // Gardé si besoin futur (paiement), sinon supprimable
  // final String _transKey = randomAlphaNumeric(15);
  
  // Pour gérer l'état de l'accordéon
  bool _isAccordionExpanded = false;

  // Fallback si coordonnées manquantes
  static const LatLng _fallbackPickup = LatLng(6.3654, 2.4183); // Cotonou
  static const LatLng _fallbackDropoff = LatLng(6.3954, 2.4483); // Calavi

  // Coordonnées dynamiques (provenant de la Delivery)
  LatLng _pickupLocation = _fallbackPickup;
  LatLng _dropoffLocation = _fallbackDropoff;
  List<LatLng> _pickupLocations = const [];

  LatLng? _currentDriverLocation;
  bool _arrivalPopupShown = false;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(AppLocalizations.of(context)!.errorUserNotConnected);
      }

      final idToken = await user.getIdToken();
      final baseUrl = getApiBaseUrl();

      // Charger les données de la commande
      final orderResponse = await Dio().get(
        '$baseUrl/orders/${widget.orderId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Charger les données de livraison
      try {
        final deliveryResponse = await Dio().get(
          '$baseUrl/deliveries/order/${widget.orderId}',
          options: Options(
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        if (mounted) {
          setState(() {
            _deliveryData = (deliveryResponse.data is Map<String, dynamic>)
                ? deliveryResponse.data['delivery'] as Map<String, dynamic>?
                : null;
          });
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          print('ℹ️ [INFO] Aucune livraison trouvée pour cette commande');
          if (mounted) {
            setState(() {
              _deliveryData = null;
            });
          }
        } else {
          rethrow;
        }
      }

      if (mounted) {
        setState(() {
          _orderData = orderResponse.data;
          _isLoading = false;
        });

        // Extraire les coordonnées de la commande/livraison
        _extractLocations();
        
        // Démarrer le suivi de position
        _startLocationTracking();
      }
    } on DioException catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.apiErrorWithDetails(
            '${e.response?.statusCode ?? ''}',
            '${e.response?.data ?? e.message}',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.errorGeneric(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  void _extractLocations() {
    // Extraire les coordonnées depuis les données de livraison ou utiliser les fallbacks
    if (_deliveryData != null) {
      final lieuDepart = _deliveryData!['lieuDepart'] as Map<String, dynamic>?;
      final lieuDestination =
          _deliveryData!['lieuDestination'] as Map<String, dynamic>?;
      final current = _deliveryData!['currentLocation'] as Map<String, dynamic>?;
      final pickupsRaw = _deliveryData!['pickups'];

      // Multi-pickups: construire la liste des lieux fournisseurs
      final pickupPoints = <LatLng>[];
      if (pickupsRaw is List) {
        for (final p in pickupsRaw) {
          if (p is Map) {
            final dep = p['lieuDepart'];
            if (dep is Map) {
              final lat = (dep['latitude'] as num?)?.toDouble();
              final lng = (dep['longitude'] as num?)?.toDouble();
              if (lat != null && lng != null) {
                pickupPoints.add(LatLng(lat, lng));
              }
            }
          }
        }
      }
      _pickupLocations = pickupPoints;

      // Pickup principal (compat): garder un point pour polyline/centering
      if (_pickupLocations.isNotEmpty) {
        _pickupLocation = _pickupLocations.first;
      } else {
        final pickupLat = (lieuDepart?['latitude'] as num?)?.toDouble();
        final pickupLng = (lieuDepart?['longitude'] as num?)?.toDouble();
        if (pickupLat != null && pickupLng != null) {
          _pickupLocation = LatLng(pickupLat, pickupLng);
        }
      }

      final dropLat = (lieuDestination?['latitude'] as num?)?.toDouble();
      final dropLng = (lieuDestination?['longitude'] as num?)?.toDouble();
      if (dropLat != null && dropLng != null) {
        _dropoffLocation = LatLng(dropLat, dropLng);
      }

      final currentLat = (current?['latitude'] as num?)?.toDouble();
      final currentLng = (current?['longitude'] as num?)?.toDouble();
      if (currentLat != null && currentLng != null) {
        _currentDriverLocation = LatLng(currentLat, currentLng);
      }
    }
    
    print('📍 [LOC] Pickup: $_pickupLocation');
    print('📍 [LOC] Dropoff: $_dropoffLocation');

    // Popup acheteur: livreur arrivé (dateArrivee existe)
    final arrived = _deliveryData?['dateArrivee'] != null;
    final deliveryId = _deliveryData?['_id']?.toString();
    if (arrived && !_arrivalPopupShown && deliveryId != null && deliveryId.isNotEmpty) {
      _arrivalPopupShown = true;
      InAppDeliveryPopup.showLivreurArrived(deliveryId: deliveryId);
    }
  }

  void _startLocationTracking() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted) return;
      try {
        final user = FirebaseAuth.instance.currentUser;
        final idToken = await user?.getIdToken();
        if (idToken == null) return;
        final baseUrl = getApiBaseUrl();
        final response = await Dio().get(
          '$baseUrl/deliveries/order/${widget.orderId}',
          options: Options(
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        if (!mounted) return;
        setState(() {
          _deliveryData = (response.data is Map<String, dynamic>)
              ? response.data['delivery'] as Map<String, dynamic>?
              : null;
        });
        _extractLocations();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _driverAnimationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(
          l10n.orderTracking,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ) : null,
      backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo en background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF8BF13)))
          : _error != null
              ? _buildErrorWidget()
              : _buildTrackingContent(),
    );
  }

  Widget _buildErrorWidget() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrderData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF8BF13),
              foregroundColor: Colors.black,
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingContent() {
    final status = _orderData!['status'] as String?;
    final isDelivered = status == 'delivered' || status == 'livrée';

    return Column(
      children: [
        // Carte agrandie qui couvre tout l'espace
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    (_pickupLocation.latitude + _dropoffLocation.latitude) / 2,
                    (_pickupLocation.longitude + _dropoffLocation.longitude) / 2,
                  ),
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.tranoo.tranoo',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [_pickupLocation, _dropoffLocation],
                        strokeWidth: 4.0,
                        color: const Color(0xFFF8BF13), // Jaune Tranoo pour la trajectoire
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      // Points fournisseurs (multi-pickups)
                      if (_pickupLocations.isNotEmpty)
                        ..._pickupLocations.map(
                          (p) => Marker(
                            point: p,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8BF13),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(
                                Icons.store,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      if (_pickupLocations.isEmpty)
                        Marker(
                          point: _pickupLocation,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8BF13),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      
                      // Destination
                      Marker(
                        point: _dropoffLocation,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      
                      // Position actuelle du livreur
                      if (_currentDriverLocation != null && !isDelivered)
                        Marker(
                          point: _currentDriverLocation!,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Section du bas - Accordéon avec fleche inversée
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFF8BF13),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.deliveryDetails,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF8BF13),
                  ),
                ),
              ],
            ),
            trailing: AnimatedRotation(
              turns: _isAccordionExpanded ? 0.5 : 0.0, // 0.5 = 180° rotation
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_up, // Pointe vers le haut par défaut
                color: const Color(0xFFF8BF13),
              ),
            ),
            backgroundColor: Colors.white,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onExpansionChanged: (isExpanded) {
              setState(() {
                _isAccordionExpanded = isExpanded;
              });
            },
            children: [
              const SizedBox(height: 8),
              
              // Profil du livreur
              _buildDriverProfile(),
              
              // Détails de la livraison (UI refondue)
              const SizedBox(height: 20),
              _buildOrderSummary(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverProfile() {
    final livreur = _deliveryData?['livreur'] as Map<String, dynamic>?;
    final nom = '${livreur?['prenoms'] ?? ''} ${livreur?['nom'] ?? ''}'.trim();
    final hasLivreur = nom.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8BF13).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar du livreur
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFF8BF13),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          
          // Informations du livreur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.driverLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF8BF13),
                  ),
                ),
                Text(
                  hasLivreur
                      ? nom
                      : AppLocalizations.of(context)!.driverAssignmentPending,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // Icônes d'action
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF8BF13),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.phone,
                    color: Color(0xFFF8BF13),
                    size: 20,
                  ),
                  onPressed: hasLivreur ? () => _callDriver() : null,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF8BF13),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.message,
                    color: Color(0xFFF8BF13),
                    size: 20,
                  ),
                  onPressed: hasLivreur ? () => _messageDriver() : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    final deliveryStatus = _deliveryData?['statut']?.toString() ?? _orderData?['status']?.toString();
    final itemsRaw = _orderData?['items'];
    final items = (itemsRaw is List) ? itemsRaw.whereType<Map>().toList() : const <Map>[];
    final first = items.isNotEmpty ? items.first : null;
    final l10n = AppLocalizations.of(context)!;
    final itemTitle = first?['title']?.toString() ??
        first?['titre']?.toString() ??
        l10n.orderLabel;
    final qty = (first?['quantity'] as num?)?.toInt() ?? (first?['quantite'] as num?)?.toInt() ?? 1;
    final isDelivered = (deliveryStatus ?? '').toLowerCase() == 'livré' || (deliveryStatus ?? '').toLowerCase() == 'delivered';
    final colisRecupere = _deliveryData?['colisRecupere'] == true;
    final arrived = _deliveryData?['dateArrivee'] != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8BF13).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress line (package -> truck -> home)
          Row(
            children: [
              _stepDot(
                icon: Icons.inventory_2_outlined,
                filled: true,
                color: const Color(0xFFF8BF13),
              ),
              Expanded(
                child: _stepLine(
                  color: const Color(0xFFF8BF13).withOpacity(colisRecupere ? 0.35 : 0.20),
                  dashed: !colisRecupere,
                ),
              ),
              _stepDot(
                icon: Icons.local_shipping_outlined,
                filled: colisRecupere,
                color: const Color(0xFFF8BF13),
              ),
              Expanded(
                child: _stepLine(
                  color: const Color(0xFFF8BF13).withOpacity(arrived ? 0.35 : 0.20),
                  dashed: !arrived,
                ),
              ),
              _stepDot(
                icon: Icons.home_outlined,
                filled: isDelivered,
                color: const Color(0xFFF8BF13),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Package card (style image)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF8BF13).withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8BF13).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2, color: Color(0xFFF8BF13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF0A1F44),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.quantityLabel(qty),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8BF13).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _formatStatus(deliveryStatus),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF8BF13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Infos non présentes sur l'image → masquées volontairement
          // const SizedBox(height: 10),
          // Text('Frais de livraison: ${deliveryFee.toStringAsFixed(0)} FCFA', ...),
          // Text('Commande #$orderId', ...),
        ],
      ),
    );
  }

  Widget _stepDot({
    required IconData icon,
    required bool filled,
    required Color color,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, size: 18, color: filled ? Colors.white : color),
    );
  }

  Widget _stepLine({
    required Color color,
    bool dashed = false,
  }) {
    if (!dashed) return Container(height: 2, color: color);
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashW = 6.0;
        final gap = 4.0;
        final count = (constraints.maxWidth / (dashW + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(width: dashW, height: 2, color: color),
          ),
        );
      },
    );
  }

  Future<void> _callDriver() async {
    final livreur = _deliveryData?['livreur'];
    final tel = livreur?['telephone']?.toString();
    if (tel == null || tel.trim().isEmpty) return;
    final uri = Uri(scheme: 'tel', path: tel.replaceAll(RegExp(r'\s'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _messageDriver() async {
    final livreur = _deliveryData?['livreur'];
    final tel = livreur?['telephone']?.toString();
    if (tel == null || tel.trim().isEmpty) return;
    final uri = Uri(scheme: 'sms', path: tel.replaceAll(RegExp(r'\s'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

}

// (Painter supprimé: plus utilisé après refonte UI)
