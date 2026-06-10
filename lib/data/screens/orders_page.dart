import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/config/backend_config.dart';
import 'order_details_page.dart';
import 'package:tranoo/l10n/app_localizations.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;
  static const List<Color> _ticketColors = [
    Color(0xFF1F69FF),
    Color(0xFF05C46B),
    Color(0xFF8B5CF6),
  ];

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
      final response = await Dio().get(
        '${getApiBaseUrl()}/orders/my-orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Normaliser les IDs MongoDB (_id -> id) pour faciliter l'utilisation
        final orders = (response.data['orders'] ?? []) as List;
        final normalizedOrders = orders.map((order) {
          final orderMap = Map<String, dynamic>.from(order);
          if (orderMap.containsKey('_id') && !orderMap.containsKey('id')) {
            orderMap['id'] = orderMap['_id'].toString();
          }
          return orderMap;
        }).toList();

        setState(() {
          _orders = normalizedOrders;
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
        _error = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        title: Text(
          l10n.myOrders,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: const Color(0xFF0A1F44),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _isLoading
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
                          onPressed: _loadOrders,
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  )
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune commande',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Commencez vos achats pour voir vos commandes ici',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _buildOrderCard(order, index);
                        },
                      ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, int index) {
    final items = order['items'] as List<dynamic>? ?? [];
    final status = order['status'] as String? ?? 'pending';
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final createdAt = order['createdAt'] as String? ?? '';
    final rawId = order['_id']?.toString() ?? order['id']?.toString() ?? '';
    final orderId = rawId.replaceAll('"', '').replaceAll("'", '').trim();
    final accent = _ticketColors[index % _ticketColors.length];
    final formattedDate =
        createdAt.isNotEmpty ? _formatDate(createdAt) : 'Date inconnue';

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsPage(
              order: Map<String, dynamic>.from(order),
              accentColor: accent,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F5),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 74,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(22),
                ),
                border: Border(
                  right: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        createdAt.isNotEmpty ? _extractDay(createdAt) : '--',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          color: Color(0xFF0A1F44),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        createdAt.isNotEmpty ? _extractMonth(createdAt) : '---',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: -8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF1F5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(22),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -1,
                      top: 8,
                      bottom: 8,
                      child: _PerforationLine(
                        dotColor: Colors.white.withOpacity(0.65),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'CMD ${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                _getStatusText(status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${items.length} article(s) • $formattedDate',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractDay(String isoDate) {
    try {
      final d = DateTime.parse(isoDate).toLocal();
      return d.day.toString().padLeft(2, '0');
    } catch (_) {
      return '--';
    }
  }

  String _extractMonth(String isoDate) {
    const months = [
      'JAN',
      'FEV',
      'MAR',
      'AVR',
      'MAI',
      'JUN',
      'JUL',
      'AOU',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    try {
      final d = DateTime.parse(isoDate).toLocal();
      return months[d.month - 1];
    } catch (_) {
      return '---';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'À l\'instant';
          }
          return 'Il y a ${difference.inMinutes} min';
        }
        return 'Il y a ${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}

class _PerforationLine extends StatelessWidget {
  final Color dotColor;
  const _PerforationLine({required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        9,
        (_) => Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
