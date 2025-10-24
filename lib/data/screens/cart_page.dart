import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import 'order_summary.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // Charger les éléments du panier au démarrage
    CartService().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          Consumer<CartService>(
            builder: (context, cart, child) {
              return Text(
                '${cart.totalQuantity}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Votre panier est vide',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez des articles pour commencer vos achats',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Image du produit
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child:
                                    item.imageUrl != null
                                        ? Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            );
                                          },
                                        )
                                        : const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Détails du produit
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  if (item.pieceType != null)
                                    Text(
                                      'Type: ${item.pieceType}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),

                                  if (item.model != null)
                                    Text(
                                      'Modèle: ${item.model}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),

                                  const SizedBox(height: 8),

                                  Text(
                                    item.priceLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Contrôles de quantité
                            Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (item.quantity > 1) {
                                          cart.updateQuantity(
                                            item.articleId,
                                            item.quantity - 1,
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      iconSize: 20,
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        cart.updateQuantity(
                                          item.articleId,
                                          item.quantity + 1,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    cart.remove(item.articleId);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Résumé et bouton de commande
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cart.subtotal.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            cart.items.isNotEmpty
                                ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const OrderSummaryPage(),
                                    ),
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Passer la commande',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
