import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/backend_config.dart';
import 'package:feexpay_flutter_v2/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';

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
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _orderData;
  Map<String, dynamic>? _deliveryData;
  List<LatLng> _routePoints = [];
  Timer? _locationUpdateTimer;
  Timer? _driverAnimationTimer;
  bool _pendingLivreurSnackShown = false;
  bool _livreurAssignedSnackShown = false;
  bool _arrivalSheetShown = false;
  String? _deliveryId;
  final String _transKey = randomAlphaNumeric(15);

  // Fallback si coordonnées manquantes
  static const LatLng _fallbackPickup = LatLng(6.3654, 2.4183); // Cotonou
  static const LatLng _fallbackDropoff = LatLng(6.3954, 2.4483); // Calavi

  // Coordonnées dynamiques (provenant de la Delivery)
  LatLng _pickupLocation = _fallbackPickup;
  LatLng _dropoffLocation = _fallbackDropoff;

  LatLng? _currentDriverLocation;
  String? _osrmRouteKey;
  String? _osrmDriverRouteKey;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _driverAnimationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    // Polling "léger" : on rafraîchit la Delivery si elle existe.
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!mounted) return;
      if (_deliveryId != null && _deliveryId!.isNotEmpty) {
        await _refreshDelivery();
      } else if (_orderData != null) {
        // Recharger la commande de temps en temps pour récupérer deliveryId
        // (ex: la Delivery vient d'être créée / liée après coup)
        await _loadOrderData(silent: true);
      }
    });
  }

  bool _shouldShowDriver() {
    final status = (_orderData?['status'] as String?)?.toLowerCase();
    // On montre le livreur seulement si assigné / en cours.
    // 'delivering' est conservé pour compatibilité d'anciens statuts.
    return status == 'assigné' || status == 'en_cours' || status == 'delivering';
  }

  Future<void> _loadOrderData({bool silent = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!silent) {
          setState(() {
            _error = 'Utilisateur non connecté';
            _isLoading = false;
          });
        }
        return;
      }

      // Nettoyer l'orderId (enlever les guillemets, espaces, etc.)
      final cleanOrderId = widget.orderId
          .replaceAll('"', '')
          .replaceAll("'", '')
          .trim();
      
      if (cleanOrderId.isEmpty) {
        setState(() {
          _error = 'ID de commande invalide';
          _isLoading = false;
        });
        return;
      }

      developer.log('Chargement commande avec ID: $cleanOrderId');
      
      final token = await user.getIdToken();
      final response = await Dio().get(
        '${getApiBaseUrl()}/orders/$cleanOrderId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final orderData = response.data;
        developer.log('Commande chargée avec succès: ${orderData['_id'] ?? orderData['id']}');
        final deliveryId = orderData['deliveryId']?.toString();

        if (!silent) {
          setState(() {
            _orderData = Map<String, dynamic>.from(orderData);
            _deliveryId = deliveryId;
            _isLoading = false;
          });
        } else {
          // Silent refresh: pas de spinner, mais mise à jour des données.
          setState(() {
            _orderData = Map<String, dynamic>.from(orderData);
            _deliveryId = deliveryId;
          });
        }

        // Si une Delivery est liée, charger les détails (coords + livreur + currentLocation)
        if (deliveryId != null && deliveryId.isNotEmpty) {
          await _loadDeliveryDetails(deliveryId);
        } else {
          // Pas encore de delivery => route fallback (visible quand même)
          _initializeRoutePoints();
          _showPendingLivreurSnackIfNeeded();
        }
      } else {
        developer.log('Erreur HTTP: ${response.statusCode}');
        if (!silent) {
          setState(() {
            _error = 'Impossible de charger les détails de la commande (Code: ${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      developer.log('Erreur lors du chargement de la commande: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          setState(() {
            _error = 'Commande non trouvée. Vérifiez que l\'ID de la commande est correct.';
            _isLoading = false;
          });
        } else {
          if (!silent) {
            setState(() {
              _error = 'Erreur de connexion: ${e.message ?? e.toString()}';
              _isLoading = false;
            });
          }
        }
      } else {
        if (!silent) {
          setState(() {
            _error = 'Erreur: ${e.toString()}';
            _isLoading = false;
          });
        }
      }
    }
  }

  void _initializeRoutePoints() {
    // D'abord fallback immédiat (UI fluide), puis OSRM (route réelle)
    _routePoints = _buildSimpleRoute(_pickupLocation, _dropoffLocation);
    _loadOsrmMainRouteIfNeeded();
  }

  Future<void> _loadOsrmMainRouteIfNeeded() async {
    final key = '${_pickupLocation.longitude},${_pickupLocation.latitude};${_dropoffLocation.longitude},${_dropoffLocation.latitude}';
    if (_osrmRouteKey == key) return;
    _osrmRouteKey = key;
    final pts = await _fetchOsrmRoute(_pickupLocation, _dropoffLocation);
    if (!mounted) return;
    if (pts != null && pts.length >= 2) {
      setState(() => _routePoints = pts);
    }
  }

  Future<void> _loadOsrmDriverRouteIfNeeded(LatLng driver) async {
    final key = '${driver.longitude},${driver.latitude};${_dropoffLocation.longitude},${_dropoffLocation.latitude}';
    if (_osrmDriverRouteKey == key) return;
    _osrmDriverRouteKey = key;
    // On ne remplace pas _routePoints ici; on utilise cette route seulement pour pointillé.
    final pts = await _fetchOsrmRoute(driver, _dropoffLocation);
    if (!mounted) return;
    if (pts != null && pts.length >= 2) {
      // Stocker dans _driverData? On réutilise _routePoints pour la route principale,
      // et on calcule le pointillé à partir d'une ligne simplifiée (driver->destination)
      // en remplaçant temporairement le pointillé: on garde la version simple par défaut.
      setState(() {
        _driverToDestRoute = pts;
      });
    }
  }

  List<LatLng>? _driverToDestRoute;

  Future<List<LatLng>?> _fetchOsrmRoute(LatLng from, LatLng to) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
      final res = await Dio().get(
        url,
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
          'alternatives': 'false',
          'steps': 'false',
        },
      );
      if (res.statusCode != 200) return null;
      final data = res.data;
      if (data is! Map) return null;
      final routes = data['routes'];
      if (routes is! List || routes.isEmpty) return null;
      final geometry = routes.first['geometry'];
      if (geometry is! Map) return null;
      final coords = geometry['coordinates'];
      if (coords is! List) return null;
      final pts = <LatLng>[];
      for (final c in coords) {
        if (c is List && c.length >= 2) {
          final lon = (c[0] as num).toDouble();
          final lat = (c[1] as num).toDouble();
          pts.add(LatLng(lat, lon));
        }
      }
      return pts;
    } catch (e) {
      developer.log('OSRM route error: $e');
      return null;
    }
  }

  Future<void> _refreshDelivery() async {
    final id = _deliveryId;
    if (id == null || id.isEmpty) return;
    await _loadDeliveryDetails(id, silent: true);
  }

  Future<void> _loadDeliveryDetails(String deliveryId, {bool silent = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      final response = await Dio().get(
        '${getApiBaseUrl()}/deliveries/$deliveryId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final delivery = (data is Map && data['delivery'] is Map)
            ? Map<String, dynamic>.from(data['delivery'])
            : Map<String, dynamic>.from(data as Map);

        final lieuDepart = delivery['lieuDepart'] as Map<String, dynamic>?;
        final lieuDestination = delivery['lieuDestination'] as Map<String, dynamic>?;
        final pickup = _latLngFromMap(lieuDepart) ?? _fallbackPickup;
        final dropoff = _latLngFromMap(lieuDestination) ?? _fallbackDropoff;

        // currentLocation du livreur si disponible
        final currentLoc = delivery['currentLocation'] as Map<String, dynamic>?;
        final liveDriver = _latLngFromMap(currentLoc);

        // livreur assigné ?
        final livreur = delivery['livreur'];
        final hasLivreur = livreur != null;

        if (!mounted) return;
        setState(() {
          _deliveryData = delivery;
          _pickupLocation = pickup;
          _dropoffLocation = dropoff;
        });

        _initializeRoutePoints();

        if (!hasLivreur) {
          // Aucun livreur associé : on garde route + pas de marker livreur
          _showPendingLivreurSnackIfNeeded();
        } else {
          _showLivreurAssignedSnackIfNeeded();
          if (liveDriver != null) {
            _animateDriverTo(liveDriver);
          }
        }

        // Si le livreur est arrivé, afficher le popup d'actions (une seule fois)
        final dateArrivee = delivery['dateArrivee'];
        if (dateArrivee != null && !_arrivalSheetShown) {
          _arrivalSheetShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showArrivalActionsSheet();
          });
        }
      }
    } catch (e) {
      // Si erreur, ne pas casser l'UI. On garde la dernière position connue.
      developer.log('Erreur loadDeliveryDetails: $e');
      if (!silent && mounted) {
        setState(() {
          _error = 'Impossible de récupérer la livraison en temps réel.';
        });
      }
    }
  }

  LatLng? _latLngFromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final lat = m['latitude'];
    final lng = m['longitude'];
    if (lat == null || lng == null) return null;
    final dLat = (lat is num) ? lat.toDouble() : double.tryParse(lat.toString());
    final dLng = (lng is num) ? lng.toDouble() : double.tryParse(lng.toString());
    if (dLat == null || dLng == null) return null;
    return LatLng(dLat, dLng);
  }

  void _animateDriverTo(LatLng target) {
    _driverAnimationTimer?.cancel();
    final start = _currentDriverLocation;
    if (start == null) {
      setState(() => _currentDriverLocation = target);
      return;
    }

    // Animation simple par interpolation (10 étapes) pour donner un effet “réaliste”
    const steps = 10;
    var i = 0;
    _driverAnimationTimer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      i++;
      final frac = i / steps;
      final lat = start.latitude + (target.latitude - start.latitude) * frac;
      final lng = start.longitude + (target.longitude - start.longitude) * frac;
      setState(() {
        _currentDriverLocation = LatLng(lat, lng);
      });
      if (i >= steps) {
        t.cancel();
      }
    });

    // Charger route OSRM driver->destination (pour pointillé réaliste)
    _loadOsrmDriverRouteIfNeeded(target);
  }

  List<LatLng> _buildSimpleRoute(LatLng from, LatLng to) {
    // Route “réaliste” simple : 3 points intermédiaires interpolés
    return [
      from,
      LatLng(
        from.latitude + (to.latitude - from.latitude) * 0.25,
        from.longitude + (to.longitude - from.longitude) * 0.25,
      ),
      LatLng(
        from.latitude + (to.latitude - from.latitude) * 0.55,
        from.longitude + (to.longitude - from.longitude) * 0.55,
      ),
      LatLng(
        from.latitude + (to.latitude - from.latitude) * 0.8,
        from.longitude + (to.longitude - from.longitude) * 0.8,
      ),
      to,
    ];
  }

  void _showPendingLivreurSnackIfNeeded() {
    if (_pendingLivreurSnackShown || !mounted) return;
    _pendingLivreurSnackShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Votre commande est enregistrée. Un livreur prendra bientôt en charge la livraison.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showLivreurAssignedSnackIfNeeded() {
    if (_livreurAssignedSnackShown || !mounted) return;
    _livreurAssignedSnackShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Livreur assigné. Suivez sa position en temps réel.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showArrivalActionsSheet() async {
    final delivery = _deliveryData ?? {};
    final totalCommande = (delivery['totalCommande'] as num?)?.toDouble() ??
        double.tryParse(delivery['totalCommande']?.toString() ?? '') ??
        (_orderData?['total'] as num?)?.toDouble() ??
        0.0;
    final fraisLivraison = (delivery['fraisLivraison'] as num?)?.toDouble() ??
        double.tryParse(delivery['fraisLivraison']?.toString() ?? '') ??
        (_orderData?['deliveryFee'] as num?)?.toDouble() ??
        0.0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.green, size: 30),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Votre livreur est arrivé',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choisissez une action pour finaliser.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 14),

                // Récap montants
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _amountRow('Total commande', '${totalCommande.toStringAsFixed(0)} FCFA'),
                      const SizedBox(height: 6),
                      _amountRow('Frais livraison', '${fraisLivraison.toStringAsFixed(0)} FCFA'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _startReturnFlow(fraisLivraison);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Retourner le colis'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _confirmReception();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Récupérer ma commande'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmReception() async {
    final deliveryId = _deliveryId;
    if (deliveryId == null || deliveryId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livraison introuvable.')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) throw Exception('Token manquant');

      final res = await Dio().post(
        '${getApiBaseUrl()}/deliveries/$deliveryId/confirm',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commande récupérée avec succès.')),
          );
        }
        await _refreshDelivery();
        await _loadOrderData(silent: true);
      } else {
        throw Exception('Erreur serveur (${res.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur récupération: $e')),
      );
    }
  }

  Widget _amountRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }

  Future<void> _startReturnFlow(double fraisLivraison) async {
    final deliveryId = _deliveryId;
    if (deliveryId == null || deliveryId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livraison introuvable.')),
      );
      return;
    }

    final reasonController = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
              top: 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Motif de retour (obligatoire)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ex: pièce non conforme, défaut, erreur de modèle…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text('Envoyer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ensuite, vous devrez payer uniquement les frais de livraison.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Motif requis.')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) throw Exception('Token manquant');

      final res = await Dio().post(
        '${getApiBaseUrl()}/deliveries/$deliveryId/request-return',
        data: jsonEncode({'reason': reason}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Retour signalé. Paiement des frais de livraison requis.')),
          );
        }
        await _startFeexpayPayment(
          amount: fraisLivraison,
          description: 'Paiement frais de livraison',
        );
      } else {
        throw Exception('Erreur serveur (${res.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur retour: $e')),
      );
    }
  }

  Future<void> _startFeexpayPayment({
    required double amount,
    required String description,
  }) async {
    try {
      final token = dotenv.env['FP_TOKEN_FEEXPAY'] ?? '';
      final idUser = dotenv.env['ID_USER_FEEXPAY'] ?? '';
      if (token.isEmpty || idUser.isEmpty) {
        throw Exception('Configuration FeexPay manquante');
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChoicePage(
            token: token,
            id: idUser,
            amount: amount.toStringAsFixed(0),
            redirecturl: '/delivery-payment-success',
            errorredirecturl: '/delivery-payment-error',
            trans_key: '${description}_${_transKey}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de paiement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(
          'Suivi de commande',
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
      ) : null, // Pas d'AppBar si showAppBar est false
      backgroundColor: const Color(0xFFF8BF13).withOpacity(0.1), // Jaune très clair Tranoo
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF8BF13)))
          : _error != null
              ? _buildErrorWidget()
              : _buildTrackingContent(),
    );
  }

  Widget _buildErrorWidget() {
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
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingContent() {
    final status = _orderData!['status'] as String?;
    final isDelivered = status == 'delivered' || status == 'livrée';
    final hasLivreur = _deliveryData?['livreur'] != null;
    final showDriver = hasLivreur && _currentDriverLocation != null && !isDelivered;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8BF13).withOpacity(0.15), // Jaune très clair
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF8BF13).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header avec statut
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF8BF13).withOpacity(0.9),
                  const Color(0xFFF8BF13),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 30,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commande #${(widget.orderId.length > 8 ? widget.orderId.substring(0, 8) : widget.orderId).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _getStatusText(status),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatStatus(status),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Timeline du statut
                _buildStatusTimeline(status),
              ],
            ),
          ),
          
          // Carte
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
                child: _buildMapWidget(),
              ),
            ),
          ),
          
          // Carte d'information du bas
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                // Trajet avec points
                _buildJourneyPoints(),
                const SizedBox(height: 16),
                
                // Informations du livreur
                if (hasLivreur) _buildDriverInfo(),
                
                // Boutons d'action
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.phone,
                        label: 'Appeler',
                        onTap: () => _callDriver(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.message,
                        label: 'Message',
                        onTap: () => _messageDriver(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.map,
                        label: 'Itinéraire',
                        onTap: () => _openRoute(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWidget() {
    final status = (_orderData?['status'] as String?)?.toLowerCase();
    // Utiliser la logique de carte existante
    return FlutterMap(
      options: MapOptions(
        center: LatLng(
          (_pickupLocation.latitude + _dropoffLocation.latitude) / 2,
          (_pickupLocation.longitude + _dropoffLocation.longitude) / 2,
        ),
        zoom: 13.0,
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
            // Point de départ
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
            if (_currentDriverLocation != null && !(status == 'delivered' || status == 'livrée'))
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
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'en_attente':
        return const Color(0xFFF8BF13); // Jaune Tranoo
      case 'confirmed':
      case 'confirmée':
        return const Color(0xFFF8BF13); // Jaune Tranoo
      case 'preparing':
      case 'en_préparation':
        return const Color(0xFFF8BF13); // Jaune Tranoo
      case 'ready':
      case 'prête':
        return const Color(0xFFF8BF13); // Jaune Tranoo
      case 'delivering':
      case 'en_livraison':
      case 'en_cours':
        return const Color(0xFFF8BF13); // Jaune Tranoo
      case 'delivered':
      case 'livrée':
        return const Color(0xFFF8BF13); // Jaune Tranoo
      case 'cancelled':
      case 'annulée':
        return Colors.red;
      case 'commandé':
        return const Color(0xFFF8BF13); // Jaune Tranoo
      case 'assigné':
        return const Color(0xFFF8BF13); // Jaune Tranoo
      default:
        return const Color(0xFFF8BF13); // Jaune Tranoo
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'en_attente':
        return Icons.pending;
      case 'confirmed':
      case 'confirmée':
        return Icons.check_circle;
      case 'preparing':
      case 'en_préparation':
        return Icons.restaurant;
      case 'ready':
      case 'prête':
        return Icons.fastfood;
      case 'delivering':
      case 'en_livraison':
      case 'en_cours':
        return Icons.local_shipping;
      case 'delivered':
      case 'livrée':
        return Icons.done_all;
      case 'cancelled':
      case 'annulée':
        return Icons.cancel;
      case 'commandé':
        return Icons.shopping_cart;
      case 'assigné':
        return Icons.person;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'en_attente':
        return 'En attente d’un livreur… vous serez notifié dès qu’il accepte la livraison.';
      case 'confirmed':
      case 'confirmée':
        return 'Votre commande a été confirmée.';
      case 'preparing':
      case 'en_préparation':
        return 'Votre commande est en préparation.';
      case 'ready':
      case 'prête':
        return 'Votre commande est prête à être livrée.';
      case 'delivering':
      case 'en_livraison':
      case 'en_cours':
        return 'Votre commande est en cours de livraison.';
      case 'delivered':
      case 'livrée':
        return 'Votre commande a été livrée.';
      case 'cancelled':
      case 'annulée':
        return 'Votre commande a été annulée.';
      case 'commandé':
        return 'Votre commande a été commandée.';
      case 'assigné':
        return 'Votre commande a été assignée à un livreur.';
      default:
        return 'Statut inconnu.';
    }
  }

  String _getDriverStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'assigné':
        return 'Livreur accepté - En route pour récupération';
      case 'en_cours':
        return 'Livreur en route vers vous';
      case 'delivering':
        return 'Livraison en cours';
      default:
        return 'Suivi en temps réel';
    }
  }

  // Nouvelles méthodes pour l'UI moderne
  String _formatStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'En préparation';
      case 'ready':
        return 'Prête';
      case 'delivering':
        return 'En livraison';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status ?? 'Inconnu';
    }
  }

  Widget _buildStatusTimeline(String? status) {
    final steps = [
      {'title': 'Commande confirmée', 'icon': Icons.check_circle, 'status': 'confirmed'},
      {'title': 'En préparation', 'icon': Icons.restaurant, 'status': 'preparing'},
      {'title': 'Prête', 'icon': Icons.inventory, 'status': 'ready'},
      {'title': 'En livraison', 'icon': Icons.local_shipping, 'status': 'delivering'},
      {'title': 'Livrée', 'icon': Icons.home, 'status': 'delivered'},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = _isStepCompleted(status, step['status'] as String);

        return Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                step['icon'] as IconData,
                size: 14,
                color: isCompleted ? const Color(0xFFF8BF13) : Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step['title'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? Colors.white : Colors.white.withOpacity(0.7),
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  bool _isStepCompleted(String? currentStatus, String stepStatus) {
    final statusOrder = ['pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered'];
    final currentIndex = statusOrder.indexOf(currentStatus?.toLowerCase() ?? 'pending');
    final stepIndex = statusOrder.indexOf(stepStatus.toLowerCase());
    return stepIndex < currentIndex;
  }

  Widget _buildJourneyPoints() {
    return Column(
      children: [
        // Point de départ - Fournisseur
        _buildJourneyPoint(
          icon: Icons.store,
          title: 'Point de départ',
          subtitle: 'Fournisseur',
          isCompleted: true,
          isFirst: true,
        ),
        
        // Ligne pointillée
        Container(
          height: 30,
          margin: const EdgeInsets.only(left: 20),
          child: CustomPaint(
            painter: DashedLinePainter(
              color: const Color(0xFFF8BF13).withOpacity(0.5),
              dashWidth: 5,
              dashSpace: 5,
            ),
          ),
        ),
        
        // Point de livraison - Client
        _buildJourneyPoint(
          icon: Icons.home,
          title: 'Destination',
          subtitle: 'Domicile client',
          isCompleted: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildJourneyPoint({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFF8BF13) : Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? const Color(0xFFF8BF13) : Colors.grey.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isCompleted ? Colors.white : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.black87 : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? Colors.black54 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    final livreur = _deliveryData?['livreur'];
    if (livreur == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8BF13).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF8BF13),
            child: Text(
              (livreur['name'] as String? ?? 'L')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  livreur['name'] as String? ?? 'Livreur',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  livreur['phone'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8BF13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'En route',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8BF13).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF8BF13).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFFF8BF13),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFF8BF13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callDriver() {
    final livreur = _deliveryData?['livreur'];
    if (livreur?['phone'] != null) {
      // Implémenter l'appel téléphonique
      print('Appeler: ${livreur['phone']}');
    }
  }

  void _messageDriver() {
    final livreur = _deliveryData?['livreur'];
    if (livreur?['phone'] != null) {
      // Implémenter l'envoi de message
      print('Message: ${livreur['phone']}');
    }
  }

  void _openRoute() {
    // Implémenter l'ouverture de l'itinéraire
    print('Ouvrir itinéraire');
  }
}

// Custom painter pour les lignes pointillées
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
