import 'package:flutter/material.dart';
import 'create_sell.dart';
import 'driver_certified.dart';// Importez la page create_sell.dart

class ProfilUtilisateurPage extends StatelessWidget {
  const ProfilUtilisateurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profil utilisateur"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte Profil
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    //backgroundImage: AssetImage("assets/images/avatar.png"),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Itunuoluwa Abidoye",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        "abidoye@itunuakwa",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Liste des options
            buildOption(context, "Mon compte",
                "Apporter des modifications à votre compte", Icons.person),
            buildOption(context, "Vendre ma voiture",
                "Devenez fournisseur et vendez avec nous", Icons.car_rental,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateSellPage()), // Redirection vers create_sell.dart
                  );
                }),
            buildOption(context, "Devenir chauffeur certifié",
                "Proposer des services de livraison", Icons.delivery_dining,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder:  (context) => DriverCertifiedPage()),
              );
            }),
            buildOption(context, "Mon portefeuille", "200000 XOF",
                Icons.account_balance_wallet,
                isHighlighted: true),
            buildOption(context, "Déconnexion", "", Icons.logout,
                color: Colors.red),

            const SizedBox(height: 20),
            const Text("Plus",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Section "Plus"
            buildOption(context, "Notifications", "", Icons.notifications,
                badge: true),
            buildOption(context, "Langue", "XOF", Icons.language),
            buildOption(context, "Devise", "XOF", Icons.monetization_on),
          ],
        ),
      ),
    );
  }

  Widget buildOption(BuildContext context, String title, String subtitle,
      IconData icon,
      {Color color = Colors.black,
        bool isHighlighted = false,
        bool badge = false,
        Function()? onTap}) {
    return InkWell(
      onTap: onTap, // Gestion du clic
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: isHighlighted ? Colors.orange : color),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: color),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
            if (badge)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}