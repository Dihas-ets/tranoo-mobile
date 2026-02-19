import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/config/backend_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  MapController? _mapController;
  LatLng? _deliveryLocation;
  LatLng? _driverLocation;
  bool _isLoading = true;
  String? _error;
  dynamic _orderData;
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadOrderData();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _updateDriverLocation();
      }
    });
  }

  Future<void> _loadOrderData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Utilisateur non connecté';
          _isLoading = false;
        });
        return;
      }

      final token = await user.getIdToken();
      final response = await Dio().get(
        '${getApiBaseUrl()}/orders/${widget.orderId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final orderData = response.data;
        setState(() {
          _orderData = orderData;
          _isLoading = false;
        });

        // Extraire les coordonnées de livraison
        final deliveryLat = orderData['deliveryLatitude'];
        final deliveryLng = orderData['deliveryLongitude'];
        
        if (deliveryLat != null && deliveryLng != null) {
          setState(() {
            _deliveryLocation = LatLng(deliveryLat.toDouble(), deliveryLng.toDouble());
          });
          
          // Centrer la carte sur la position de livraison
          _mapController?.move(_deliveryLocation!, 15.0);
        }

        // Charger la position du livreur si la commande est en livraison
        if (orderData['status'] == 'delivering') {
          await _updateDriverLocation();
        }
      } else {
        setState(() {
          _error = 'Erreur lors du chargement de la commande';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDriverLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      final response = await Dio().get(
        '${getApiBaseUrl()}/orders/${widget.orderId}/driver-location',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final driverData = response.data;
        final driverLat = driverData['latitude'];
        final driverLng = driverData['longitude'];
        
        if (driverLat != null && driverLng != null) {
          setState(() {
            _driverLocation = LatLng(driverLat.toDouble(), driverLng.toDouble());
          });
        }
      }
    } catch (e) {
      // Ignorer les erreurs de mise à jour de position
      print('Erreur mise à jour position: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.indigo;
      case 'delivering':
        return Colors.green;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
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
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suivi de Commande',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
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
                )
              : _buildTrackingContent(),
    );
  }

  Widget _buildTrackingContent() {
    return Column(
      children: [
        // Carte de suivi
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _deliveryLocation != null
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _deliveryLocation!,
                        zoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.tranoo.tranoo',
                        ),
                        
                        // Marqueur de destination
                        if (_deliveryLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _deliveryLocation!,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              
                              // Marqueur du livreur
                              if (_driverLocation != null)
                                Marker(
                                  point: _driverLocation!,
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.delivery_dining,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        
                        // Ligne entre livreur et destination
                        if (_driverLocation != null && _deliveryLocation != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [_driverLocation!, _deliveryLocation!],
                                strokeWidth: 3.0,
                                color: Colors.green.withOpacity(0.7),
                              ),
                            ],
                          ),
                      ],
                    )
                  : const Center(
                      child: Text('Position de livraison non disponible'),
                    ),
            ),
          ),
        ),
        
        // Informations de la commande
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statut de la commande
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_orderData['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: _getStatusColor(_orderData['status']),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _getStatusText(_orderData['status']),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_orderData['status']),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Timeline de suivi
                _buildTrackingTimeline(),
                
                const Spacer(),
                
                // Informations de contact
                if (_orderData['status'] == 'delivering') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Contacter le livreur',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Implémenter l'appel au livreur
                          },
                          icon: const Icon(
                            Icons.call,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline() {
    final status = _orderData['status'] as String? ?? 'pending';
    final steps = [
      {'title': 'Commande confirmée', 'icon': Icons.check_circle, 'status': 'confirmed'},
      {'title': 'En préparation', 'icon': Icons.restaurant, 'status': 'preparing'},
      {'title': 'Prête', 'icon': Icons.done_all, 'status': 'ready'},
      {'title': 'En livraison', 'icon': Icons.delivery_dining, 'status': 'delivering'},
      {'title': 'Livrée', 'icon': Icons.home, 'status': 'delivered'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suivi de livraison',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ...steps.map((step) {
          final isActive = step['status'] == status;
          final isCompleted = _getStepIndex(step['status'] as String) <= _getStepIndex(status);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  int _getStepIndex(String status) {
    const steps = ['confirmed', 'preparing', 'ready', 'delivering', 'delivered'];
    return steps.indexOf(status);
  }
}
