import 'package:flutter/material.dart';
import 'succes.dart'; // Assurez-vous que ce chemin est correct

class FinalisationAchatScreen extends StatelessWidget {
  final String? articleImage; // URL image (peut être vide)
  final String articleTitle;
  final String articlePrice; // nombre en string
  final String? tarifChoisit; // montant transitaire en string
  const FinalisationAchatScreen({
    super.key,
    this.articleImage,
    required this.articleTitle,
    required this.articlePrice,
    this.tarifChoisit,
  });

  @override
  Widget build(BuildContext context) {
    // Données dynamiques
    final String displayedImage =
        (articleImage != null && articleImage!.isNotEmpty)
            ? articleImage!
            : 'assets/images/car.png';
    final String carTitle = articleTitle;
    final String carPrice = articlePrice; // attendu sans suffixe ' f'
    final String fraisTransits = tarifChoisit ?? '0';
    // TODO: récup depuis BDD plus tard
    const String fraisSupplementaires = '0';

    // Calcul du prix total
    final double base =
        double.tryParse(carPrice.replaceAll(',', '').replaceAll(' f', '')) ?? 0;
    final double transit =
        double.tryParse(
          fraisTransits.replaceAll(',', '').replaceAll(' f', ''),
        ) ??
        0;
    final double supp =
        double.tryParse(
          fraisSupplementaires.replaceAll(',', '').replaceAll(' f', ''),
        ) ??
        0;
    final double prixFinal = base + transit + supp;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Finalisation de l\'achat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la voiture
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    (displayedImage.startsWith('http'))
                        ? Image.network(
                          displayedImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          displayedImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
              ),
            ),
            const SizedBox(height: 24),

            // Titre de la voiture
            Text(
              carTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Prix de la voiture
            _buildPriceRow('Prix', carPrice.toString()),
            const SizedBox(height: 8),

            // Frais de transit
            _buildPriceRow(
              'Tarif transitaire choisi',
              fraisTransits.toString(),
            ),
            const SizedBox(height: 8),

            // Frais supplémentaires
            _buildPriceRow('Frais supplémentaires', fraisSupplementaires),
            const SizedBox(height: 16),

            // Prix total
            const Divider(),
            _buildPriceRow(
              'Prix total',
              '${prixFinal.toStringAsFixed(0)} f',
              isBold: true,
              color: Colors.amber,
            ),
            const Divider(),
            const SizedBox(height: 24),

            // Bouton de paiement
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SuccesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Payer maintenant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
