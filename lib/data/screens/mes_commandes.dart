import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/user_service.dart';
import 'order_tracking_page_modern.dart'; // Import de la page de tracking

class MesCommandesPage extends StatefulWidget {
  const MesCommandesPage({super.key});

  @override
  State<MesCommandesPage> createState() => _MesCommandesPageState();
}

class _MesCommandesPageState extends State<MesCommandesPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'tracking'; // Tracking par défaut (index 0)

  @override
  void initState() {
    super.initState();
    _loadOrders();
    // Forcer le rechargement des commandes après un court délai pour s'assurer d'avoir les dernières données
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadOrders(); // Double appel pour s'assurer que les données sont à jour
      }
    });
    // Plus de navigation automatique vers tracking
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

      print('Chargement des commandes depuis: /orders/my-orders');
      final response = await dio.get('/orders/my-orders');
      
      print('Réponse API: ${response.statusCode}');
      print('Données reçues: ${response.data}');
      
      if (response.statusCode == 200) {
        final orders = List<Map<String, dynamic>>.from(response.data['orders'] ?? []);
        print('Nombre de commandes chargées: ${orders.length}');
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      } else {
        print('Erreur API: ${response.statusCode} - ${response.data}');
        setState(() {
          _error = 'Impossible de charger vos commandes';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des commandes: $e');
      setState(() {
        _error = 'Erreur lors du chargement des commandes';
        _isLoading = false;
      });
    }
  }

  bool _isOrderActive(String statusRaw) {
    final status = statusRaw.toLowerCase();
    return ![
      'delivered',
      'livré',
      'livree',
      'cancelled',
      'annulé',
      'annule',
      'refusé',
      'refuse',
      'retour',
    ].contains(status);
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
      backgroundColor: const Color(0xFFFFF3CD), // Fond jaune clair Tranoo
      appBar: AppBar(
        title: const Text(
          'Mes commandes',
          style: TextStyle(color: Color(0xFF000000)), // Titre en noir
        ),
        backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo
        foregroundColor: const Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filtres
          _buildFilters(),
          // Contenu
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF8BF13)))
                : _error != null
                    ? _buildErrorWidget()
                    : _orders.isEmpty
                        ? _buildEmptyWidget()
                        : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'id': 'tracking', 'label': 'Tracking', 'icon': Icons.location_on},
      {'id': 'all', 'label': 'Tous', 'icon': Icons.list},
      {'id': 'inprogress', 'label': 'En cours', 'icon': Icons.local_shipping},
      {'id': 'delivered', 'label': 'Terminée', 'icon': Icons.check_circle},
      {'id': 'rejected', 'label': 'Rejetée', 'icon': Icons.cancel},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8BF13).withOpacity(0.1), // Jaune très clair
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8BF13).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            return _buildFilterButton(filter);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterButton(Map<String, dynamic> filter) {
    final isSelected = _selectedFilter == filter['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter['id'] as String;
        });
        // Plus de navigation vers tracking - on affiche directement
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFF8BF13) // Jaune Tranoo pour le sélectionné
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filter['icon'] as IconData,
              size: 20,
              color: isSelected 
                  ? const Color(0xFF000000) // Noir pour le sélectionné
                  : const Color(0xFF000000).withOpacity(0.6), // Noir transparent
            ),
            const SizedBox(height: 4),
            Text(
              filter['label'] as String,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? const Color(0xFF000000) // Noir pour le sélectionné
                    : const Color(0xFF000000).withOpacity(0.6), // Noir transparent
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTracking() {
    // Trouver la dernière commande active (non livrée)
    final activeOrders = _orders.where((order) {
      final status = (order['status'] as String).toLowerCase();
      return _isOrderActive(status);
    }).toList();
    
    if (activeOrders.isNotEmpty) {
      // Trier par date et prendre la plus récente
      activeOrders.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt']);
        final dateB = DateTime.parse(b['createdAt']);
        return dateB.compareTo(dateA); // Plus récente en premier
      });
      
      final latestOrder = activeOrders.first;
      final orderId = latestOrder['_id'].toString();
      
      // Naviguer directement vers la page de tracking moderne (pas de liste)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingPageModern(orderId: orderId),
        ),
      );
    } else {
      // Afficher un message si aucune commande active
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune commande active à tracker'),
          backgroundColor: Color(0xFFF8BF13),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFF8BF13), // Jaune Tranoo
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 16, color: Color(0xFFF8BF13)), // Jaune Tranoo
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

  Widget _buildTrackingContent() {
    print('🔍 [TRACKING] Construction du contenu de tracking...');
    print('🔍 [TRACKING] Nombre total de commandes: ${_orders.length}');
    
    // Trouver la dernière commande active (non livrée)
    final activeOrders = _orders.where((order) {
      final status = (order['status'] as String).toLowerCase();
      final isActive = _isOrderActive(status);
      print('🔍 [TRACKING] Commande ${order['_id']}: status=$status, active=$isActive');
      return isActive;
    }).toList();
    
    print('🔍 [TRACKING] Nombre de commandes actives: ${activeOrders.length}');
    
    if (activeOrders.isEmpty) {
      print('📭 [TRACKING] Aucune commande active trouvée');
      // Aucune commande active
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: const Color(0xFFF8BF13).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande active à tracker',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos commandes terminées ou annulées n\'apparaissent pas ici',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Trier par date et prendre la plus récente
    activeOrders.sort((a, b) {
      final dateA = DateTime.parse(a['createdAt']);
      final dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA); // Plus récente en premier
    });
    
    final latestOrder = activeOrders.first;
    final orderId = latestOrder['_id'].toString();
    
    print('🎯 [TRACKING] Dernière commande active: $orderId');
    print('📊 [TRACKING] Données complètes: ${latestOrder}');
    
    // Afficher le contenu de tracking directement
    return OrderTrackingPageModern(
                orderId: orderId,
                showAppBar: false, // Pas d'AppBar dans l'onglet
              );
  }

  Widget _buildOrdersList() {
    // Si le filtre tracking est sélectionné, afficher le contenu de tracking directement
    if (_selectedFilter == 'tracking') {
      return _buildTrackingContent();
    }
    
    // Filtrer les commandes selon le filtre sélectionné
    List<Map<String, dynamic>> filteredOrders = _orders;
    
    if (_selectedFilter != 'all') {
      filteredOrders = _orders.where((order) {
        final status = (order['status'] as String).toLowerCase();
        switch (_selectedFilter) {
          case 'inprogress':
            return _isOrderActive(status);
          case 'delivered':
            return ['delivered', 'livré', 'livree', 'ready', 'livré']
                .contains(status);
          case 'rejected':
            return ['cancelled', 'annulé', 'annule', 'refusé', 'refuse', 'retour']
                .contains(status);
          default:
            return true;
        }
      }).toList();
    }
    
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: const Color(0xFFF8BF13),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final total = (order['total'] is int ? (order['total'] as int).toDouble() : order['total'] as double);
    final createdAt = DateTime.parse(order['createdAt']);
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    
    // Couleurs dynamiques avec le jaune Tranoo dominant
    final colors = [
      const Color(0xFFF8BF13), // Jaune Tranoo principal
      const Color(0xFFB8860B), // Jaune foncé
      const Color(0xFFF8BF13).withOpacity(0.8), // Jaune moyen
      const Color(0xFFF8BF13).withOpacity(0.6), // Jaune clair
    ];
    final idHash = order['_id'].toString().hashCode;
    final accentColor = colors[idHash.abs() % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc pour les cartes
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF8BF13).withOpacity(0.15), // Ombre jaune Tranoo
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          // Navigation vers détails commande
          Navigator.pushNamed(
            context,
            '/order-details',
            arguments: {
              'order': order,
              'accentColor': accentColor,
            },
          );
        },
        child: Row(
          children: [
            // Section gauche avec zigzag
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
                decoration: BoxDecoration(
                  color: accentColor, // Jaune Tranoo dynamique
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec numéro et statut
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'CMD #${order['_id'].toString().substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _statusChip(_getStatusText(status), Colors.white),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Location
                    Text(
                      order['deliveryAddress']?.split(',').first ?? 'Cotonou, Bénin',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Time
                    Text(
                      '${createdAt.hour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Articles preview
                    if (items.isNotEmpty) ...[
                      Text(
                        items.take(2).map((item) => item['title']).join(', '),
                        style: const TextStyle(
                            color: Color(0xB3FFFFFF), // white80 équivalent
                            fontSize: 11,
                          ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // Prix
                    Text(
                      '${total.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Ligne zigzag
            Container(
              width: 20,
              height: 120,
              child: CustomPaint(
                painter: ZigzagPainter(),
              ),
            ),
            
            // Section droite avec date
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(22),
                ),
                border: Border(
                  left: BorderSide(
                    color: const Color(0xFFF8BF13).withOpacity(0.2), // Bordure jaune Tranoo
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    createdAt.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: Color(0xFF0A1F44),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getMonthAbbreviation(createdAt.month),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    createdAt.year.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'JAN', 'FEV', 'MAR', 'AVR', 'MAI', 'JUI',
      'JUL', 'AOU', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }
}

class ZigzagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF3CD) // Jaune clair Tranoo pour l'effet zigzag
      ..style = PaintingStyle.fill;

    final path = Path();
    final double step = 6; // Plus petit pour un zigzag plus dense
    final double amplitude = 6; // Plus prononcé
    
    // Créer le chemin zigzag
    path.moveTo(0, 0);
    
    for (double y = 0; y < size.height; y += step) {
      final x = ((y / step).floor() % 2 == 0) ? amplitude : 0.0;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Dessiner la bordure pour mieux définir le zigzag
    final borderPaint = Paint()
      ..color = const Color(0xFFF8BF13).withOpacity(0.3) // Bordure jaune Tranoo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    final borderPath = Path();
    borderPath.moveTo(0, 0);
    
    for (double y = 0; y < size.height; y += step) {
      final x = ((y / step).floor() % 2 == 0) ? amplitude : 0.0;
      borderPath.lineTo(x, y);
    }
    
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
