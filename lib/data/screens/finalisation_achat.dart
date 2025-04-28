// import 'package:flutter/material.dart';
// import 'succes.dart'; // Assurez-vous que ce chemin est correct

// // class FinalisationAchatScreen extends StatelessWidget {
// //   final String carImage;
// //   final String carTitle;
// //   final String carPrice;
// //   final String fraisTransits;
// //   final String fraisSupplementaires;

// //   const FinalisationAchatScreen({
// //     Key? key,
// //     required this.carImage,
// //     required this.carTitle,
// //     required this.carPrice,
// //     required this.fraisTransits,
// //     required this.fraisSupplementaires,
// //   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Calcul du prix total
//     final double prixFinal = double.parse(carPrice.replaceAll(',', '').replaceAll(' f', '')) +
//         double.parse(fraisTransits.replaceAll(',', '').replaceAll(' f', '')) +
//         double.parse(fraisSupplementaires.replaceAll(',', '').replaceAll(' f', ''));

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Finalisation de l\'achat',
//           style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image de la voiture
//             Center(
//               child: Container(
//                 height: 200,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     image: AssetImage(carImage),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Titre de la voiture
//             Text(
//               carTitle,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             // Prix de la voiture
//             _buildPriceRow('Prix de la voiture', carPrice),
//             const SizedBox(height: 8),

//             // Frais de transit
//             _buildPriceRow('Frais de transit', fraisTransits),
//             const SizedBox(height: 8),

//             // Frais supplémentaires
//             _buildPriceRow('Frais supplémentaires', fraisSupplementaires),
//             const SizedBox(height: 16),

//             // Prix total
//             const Divider(),
//             _buildPriceRow(
//               'Prix total',
//               '${prixFinal.toStringAsFixed(0)} f',
//               isBold: true,
//               color: Colors.amber,
//             ),
//             const Divider(),
//             const SizedBox(height: 24),

//             // Bouton de paiement
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const SuccesScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.amber,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'Payer maintenant',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? color}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: color ?? Colors.black,
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'succes.dart'; // Assurez-vous que ce chemin est correct

class FinalisationAchatScreen extends StatelessWidget {
  const FinalisationAchatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Données d'exemple
    const String carImage = 'assets/images/car.png'; // Exemple d'image
    const String carTitle = 'Toyota Corolla'; // Exemple de titre
    const String carPrice = '18,000,000 f'; // Exemple de prix de la voiture
    const String fraisTransits = '50,000 f'; // Exemple de frais de transit
    const String fraisSupplementaires = '20,000 f'; // Exemple de frais supplémentaires

    // Calcul du prix total
    final double prixFinal = double.parse(carPrice.replaceAll(',', '').replaceAll(' f', '')) +
        double.parse(fraisTransits.replaceAll(',', '').replaceAll(' f', '')) +
        double.parse(fraisSupplementaires.replaceAll(',', '').replaceAll(' f', ''));

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
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de la voiture
            Center(
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage(carImage),
                    fit: BoxFit.cover,
                  ),
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
            _buildPriceRow('Prix de la voiture', carPrice),
            const SizedBox(height: 8),

            // Frais de transit
            _buildPriceRow('Frais de transit', fraisTransits),
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
                    MaterialPageRoute(builder: (context) => const SuccesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
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