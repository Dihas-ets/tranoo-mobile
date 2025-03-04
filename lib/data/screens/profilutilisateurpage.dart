import 'package:flutter/material.dart';

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
            buildOption("Mon compte",
                "Apporter des modifications à votre compte", Icons.person),
            buildOption("Vendre ma voiture",
                "Devenez fournisseur et vendez avec nous", Icons.car_rental),
            buildOption("Devenir chauffeur certifié",
                "Proposer des services de livraison", Icons.delivery_dining),
            buildOption(
                "Mon portefeuille", "200000 XOF", Icons.account_balance_wallet,
                isHighlighted: true),
            buildOption("Déconnexion", "", Icons.logout, color: Colors.red),

            const SizedBox(height: 20),
            const Text("Plus",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Section "Plus"
            buildOption("Notifications", "", Icons.notifications, badge: true),
            buildOption("Langue", "XOF", Icons.language),
            buildOption("Devise", "XOF", Icons.monetization_on),
          ],
        ),
      ),
    );
  }

  Widget buildOption(String title, String subtitle, IconData icon,
      {Color color = Colors.black,
      bool isHighlighted = false,
      bool badge = false}) {
    return Container(
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
    );
  }
}
