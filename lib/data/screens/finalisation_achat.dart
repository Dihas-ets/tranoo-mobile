import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'succes.dart';

class FinalisationAchatScreen extends StatelessWidget {
  final String? articleImage;
  final String articleTitle;
  final String articlePrice;
  final String? tarifChoisit;
  const FinalisationAchatScreen({
    super.key,
    this.articleImage,
    required this.articleTitle,
    required this.articlePrice,
    this.tarifChoisit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String displayedImage =
        (articleImage != null && articleImage!.isNotEmpty)
            ? articleImage!
            : 'assets/images/car.png';
    final String carTitle = articleTitle;
    final String carPrice = articlePrice;
    final String fraisTransits = tarifChoisit ?? '0';
    const String fraisSupplementaires = '0';

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
        title: Text(
          l10n.finalizePurchase,
          style: const TextStyle(
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
            Text(
              carTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPriceRow(l10n.price, carPrice.toString()),
            const SizedBox(height: 8),
            _buildPriceRow(l10n.chosenForwarderRate, fraisTransits.toString()),
            const SizedBox(height: 8),
            _buildPriceRow(l10n.additionalFees, fraisSupplementaires),
            const SizedBox(height: 16),
            const Divider(),
            _buildPriceRow(
              l10n.totalPrice,
              '${prixFinal.toStringAsFixed(0)} f',
              isBold: true,
              color: Colors.amber,
            ),
            const Divider(),
            const SizedBox(height: 24),
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
                child: Text(
                  l10n.payNow,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
