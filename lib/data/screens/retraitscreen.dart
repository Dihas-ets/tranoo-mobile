import 'package:flutter/material.dart';
import 'mesretraitspage.dart'; // Vérifie si ce chemin est correct et que MesRetraitsPage existe

class RetraitScreen extends StatelessWidget {
  const RetraitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Effectuer un retrait",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Retour à la page précédente
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {}, // Tu peux ajouter un événement pour ce bouton
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3), // Ombre subtile
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Utiliser l'espace nécessaire
              crossAxisAlignment: CrossAxisAlignment.center, // Centrer les éléments horizontalement
              children: [
                const Text(
                  "Retrait",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text("Compte de virement"),
                // Regrouper les images avec un espacement réduit
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8), // Coins arrondis
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centrer les images horizontalement
                    children: [
                      _buildImage('assets/images/American Express.png'),
                      const SizedBox(width: 10), // Espacement réduit entre les images
                      _buildImage('assets/images/Visa.png'),
                      const SizedBox(width: 10),
                      _buildImage('assets/images/American Express.png'),
                      const SizedBox(width: 10),
                      _buildImage('assets/images/Discover.png'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField("Nom sur la carte", "Rencontrez Patel"),
                const SizedBox(height: 35),
                _buildTextField("Numéro de carte", "0000 0000 0000 0000"),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown("Mois", ["01", "02", "03", "04"]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown("Année", ["2024", "2025", "2026"]),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                _buildTextField(
                  "Code de sécurité de la carte",
                  "Code",
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                // Le bouton est dans un conteneur rectangulaire sans bord arrondi
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth < 600 ? screenWidth * 0.9 : 600,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0Xfff8bf13),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight < 600 ? 5 : 15,
                        horizontal: screenWidth < 600 ? 10 : 60,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // Enlever les coins arrondis
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MesRetraitsPage(),
                        ), // Navigation vers la page MesRetraitsPage
                      );
                    },
                    child: const Text(
                      "Demander un Retrait",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour le champ de texte
  Widget _buildTextField(
    String label,
    String hint, {
    bool obscureText = false,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label, // Le texte du label est maintenant en dehors du champ
        hintText: hint, // Le placeholder à l'intérieur du champ
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  // Widget pour le menu déroulant
  Widget _buildDropdown(String hint, List<String> items) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: hint, // Le texte du label est en dehors du champ
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {},
    );
  }

  // Widget personnalisé pour afficher l'image
  Widget _buildImage(String imagePath) {
    return SizedBox(
      height: 30, // Taille de l'image
      width: 50, // Largeur réduite pour la taille de la case
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain, // Ajuster l'image dans le container
      ),
    );
  }
}