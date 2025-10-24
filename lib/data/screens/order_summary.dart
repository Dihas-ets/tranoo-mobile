import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feexpay_flutter/feexpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../services/cart_service.dart';
import '../../services/user_service.dart';

enum PaymentMethod { cash, online }

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  double _deliveryFee = 720; // Calculé automatiquement
  double _discount = 500; // Calculé automatiquement
  bool _isProcessing = false;
  final String _transKey = randomAlphaNumeric(15);

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résumé'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          final double subtotal = cart.subtotal;
          final double total = (subtotal + _deliveryFee - _discount).clamp(
            0,
            double.infinity,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mon panier (liste courte)
                const Text(
                  'Mon panier',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...cart.items.map(
                  (i) => Padding(
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
                  ),
                ),
                const Divider(height: 24),

                // Livraison à
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Livraison à',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectLocationFromList(),
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('Choisir sur la carte'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'Adresse de livraison',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLength: 500,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Ajouter une note de livraison',
                    border: OutlineInputBorder(),
                    counterText: '0/500',
                  ),
                ),

                const SizedBox(height: 8),
                // Total de la commande
                const Text(
                  'Total de la commande',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _rowKV('Sous-total', '${subtotal.toStringAsFixed(0)} F'),
                const SizedBox(height: 6),
                _rowKV(
                  'Frais de livraison',
                  '${_deliveryFee.toStringAsFixed(0)} F',
                ),
                const SizedBox(height: 6),
                _rowKV(
                  'Remise sur la livraison',
                  '-${_discount.toStringAsFixed(0)} F',
                ),
                const Divider(height: 24),
                _rowKV('Total', '${total.toStringAsFixed(0)} F', isBold: true),

                const SizedBox(height: 16),
                // Mode de paiement
                const Text(
                  'Mode de paiement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () => setState(() => _method = PaymentMethod.cash),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                _method == PaymentMethod.cash
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.money, size: 18),
                        label: const Text('Espèces'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () =>
                                setState(() => _method = PaymentMethod.online),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                _method == PaymentMethod.online
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.credit_card, size: 18),
                        label: const Text('En ligne'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        cart.items.isEmpty || _isProcessing
                            ? null
                            : () async {
                              if (_method == PaymentMethod.cash) {
                                // Confirmer commande espèces
                                final confirmed = await _confirmCashOrder();
                                if (confirmed && mounted) {
                                  await _processCashOrder(total, cart);
                                }
                                return;
                              }
                              // Auto-redirection directe vers FeexPay
                              await _processOnlinePayment(total);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isProcessing
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text('Commander • ${total.toStringAsFixed(0)} F'),
                  ),
                ),
              ],
            ),
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
      builder:
          (context) => AlertDialog(
            title: const Text('Sélectionner une adresse'),
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
                child: const Text('Annuler'),
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

  Future<bool> _confirmCashOrder() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.money,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Paiement à la livraison',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vous avez choisi le paiement à la livraison.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Vous serez facturé lors de la réception de votre commande.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirmer la commande',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _processCashOrder(double total, CartService cart) async {
    setState(() => _isProcessing = true);

    try {
      // Enregistrer la commande en BDD
      await _saveOrderToDatabase(total, cart, 'cash');

      if (mounted) {
        // Vider le panier
        await cart.clear();

        // Afficher le modal de succès
        await _showSuccessModal();

        // Retourner à l'accueil
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _processOnlinePayment(double total) async {
    setState(() => _isProcessing = true);

    try {
      final token = dotenv.env['FP_TOKEN_FEEXPAY'] ?? '';
      final idUser = dotenv.env['ID_USER_FEEXPAY'] ?? '';

      if (token.isEmpty || idUser.isEmpty) {
        throw Exception('Configuration FeexPay manquante');
      }

      // Redirection directe vers FeexPay
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChoicePage(
                token: token,
                id: idUser,
                amount: total.toStringAsFixed(0),
                redirecturl: '/cart-payment-success',
                errorredirecturl: '/cart-payment-error',
                trans_key: _transKey,
              ),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de paiement: $e'),
            backgroundColor: Colors.red,
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

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

    final orderData = {
      'items':
          cart.items
              .map(
                (item) => {
                  'articleId': item.articleId,
                  'title': item.title,
                  'quantity': item.quantity,
                  'unitPrice': item.unitPrice,
                  'totalPrice': item.totalPrice,
                },
              )
              .toList(),
      'subtotal': cart.subtotal,
      'deliveryFee': _deliveryFee,
      'discount': _discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'deliveryAddress': _addressController.text.trim(),
      'deliveryNote': _noteController.text.trim(),
      'status': paymentMethod == 'cash' ? 'pending' : 'paid',
    };

    await dio.post('/orders', data: orderData);
  }

  Future<void> _showSuccessModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
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
                const Text(
                  'Commande confirmée !',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Votre commande a été enregistrée avec succès.',
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
                          const Text(
                            'Livraison prévue',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Entre 3 et 7 jours ouvrables',
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
                          const Text(
                            'Vous recevrez une notification',
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Parfait !',
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
}
