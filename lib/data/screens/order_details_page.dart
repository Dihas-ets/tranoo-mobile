import 'package:flutter/material.dart';
import 'order_tracking_page_modern.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color accentColor;

  const OrderDetailsPage({
    super.key,
    required this.order,
    this.accentColor = const Color(0xFF1F69FF),
  });

  String _statusText(String status) {
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
      case 'en_cours':
        return 'En livraison';
      case 'assigné':
        return 'Livreur assigné';
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
    final status = order['status']?.toString() ?? 'pending';
    final orderId =
        (order['_id']?.toString() ?? order['id']?.toString() ?? 'N/A').trim();
    final deliveryId = order['deliveryId']?.toString() ?? '';
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final createdAt = order['createdAt']?.toString();
    final deliveryAddress = order['deliveryAddress']?.toString() ?? 'Adresse non spécifiée';
    final items = (order['items'] as List<dynamic>? ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0A1F44),
        elevation: 0,
        title: const Text('Détails de commande'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withOpacity(0.65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tranoo Delivery',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CMD ${orderId.length > 10 ? orderId.substring(0, 10).toUpperCase() : orderId.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _statusText(status),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${total.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: -34,
                  child: Container(
                    width: 116,
                    height: 116,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: 'TRN_ORDER:$orderId|DELIVERY:$deliveryId',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 46),
            // Détails livraison - refonte UI (sans changer logique/couleurs)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header "delivery personnel" (si pas d'info livreur, on masque le nom)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: accentColor.withOpacity(0.18),
                        child: Icon(Icons.person, color: accentColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pas de nom livreur dans order payload → on affiche seulement le rôle
                            const Text(
                              'Livreur',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF0A1F44),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tranoo Delivery',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Boutons actions (si téléphone non disponible → on masque)
                      // NOTE: à activer quand le payload contient le téléphone livreur
                      // IconButton(icon: Icon(Icons.chat_bubble_outline, color: accentColor), onPressed: () {}),
                      // IconButton(icon: Icon(Icons.phone_outlined, color: accentColor), onPressed: () {}),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Ligne de progression (package -> truck -> home)
                  Row(
                    children: [
                      _stepDot(icon: Icons.inventory_2_outlined, color: accentColor, filled: true),
                      Expanded(child: _stepLine(color: accentColor.withOpacity(0.35))),
                      _stepDot(icon: Icons.local_shipping_outlined, color: accentColor, filled: true),
                      Expanded(child: _stepLine(color: accentColor.withOpacity(0.20), dashed: true)),
                      _stepDot(icon: Icons.home_outlined, color: accentColor, filled: false),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Carte "colis"
                  Builder(builder: (context) {
                    if (items.isEmpty) return const SizedBox.shrink();
                    final first = items.first as Map<String, dynamic>;
                    final title = first['title']?.toString() ?? 'Article';
                    final qty = (first['quantity'] as num?)?.toInt() ?? 1;
                    // Infos non présentes dans le payload → masquées (comme demandé)
                    // final code = first['code']?.toString();
                    // final weight = first['weight']?.toString();
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withOpacity(0.12)),
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
                              color: accentColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.inventory_2, color: accentColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
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
                                  'Qté: x$qty',
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
                              color: accentColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statusText(status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Adresse (garde la même info, mais UI plus compacte)
                  Text(
                    'Adresse de livraison',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.70),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    deliveryAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _meta('Date', createdAt ?? '-'),
                      _meta('Statut', _statusText(status), color: accentColor),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingPageModern(orderId: orderId),
                        ),
                      );
                    },
                    child: const Text('Direction'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingPageModern(orderId: orderId),
                        ),
                      );
                    },
                    child: const Text('Traquer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String title, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, color: color ?? Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _stepDot({
    required IconData icon,
    required Color color,
    required bool filled,
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
    if (!dashed) {
      return Container(height: 2, color: color);
    }
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
}

class QrImageView extends StatelessWidget {
  final String data;
  const QrImageView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final encoded = Uri.encodeComponent(data);
    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=$encoded';
    return Image.network(
      qrUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2, size: 60),
    );
  }
}

