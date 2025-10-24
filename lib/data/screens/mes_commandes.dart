import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';

class MesCommandesPage extends StatefulWidget {
  const MesCommandesPage({super.key});

  @override
  State<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends State<MesCommandesPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
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
      final dio = Dio(
        BaseOptions(
          baseUrl: UserService().dio.options.baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await dio.get('/orders/my-orders');
      
      if (response.statusCode == 200) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response.data['orders'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement des commandes';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payée';
      case 'processing':
        return 'En cours de traitement';
      case 'shipped':
        return 'Expédiée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'paid':
        return Icons.payment;
      case 'processing':
        return Icons.build;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _orders.isEmpty
                  ? _buildEmptyWidget()
                  : _buildOrdersList(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrders,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune commande',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez pas encore passé de commande',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final total = order['total'] as double;
    final createdAt = DateTime.parse(order['createdAt']);
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut et date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order['_id'].toString().substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 14,
                        color: _getStatusColor(status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
            const SizedBox(height: 12),
            
            // Articles
            if (items.isNotEmpty) ...[
              const Text(
                'Articles:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '${item['quantity']}x ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
              if (items.length > 3)
                Text(
                  '+${items.length - 3} autres articles',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 8),
            ],
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${total.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            
            // Informations de livraison
            if (order['deliveryAddress'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order['deliveryAddress'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            
            // Numéro de suivi
            if (order['trackingNumber'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Suivi: ${order['trackingNumber']}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
