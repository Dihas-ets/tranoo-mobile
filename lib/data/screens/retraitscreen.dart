import 'package:flutter/material.dart';

import 'mesretraitspage.dart'; // Vérifie si ce chemin est correct et que MesRetraitsPage existe

class RetraitScreen extends StatelessWidget {
  const RetraitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Effectuer un retrait",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed:
              () => Navigator.pop(context), // Retour à la page précédente
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {}, // Tu peux ajouter un événement pour ce bouton
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 20),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3), // Ombre subtile
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Utiliser l'espace nécessaire
            crossAxisAlignment:
                CrossAxisAlignment
                    .center, // Centrer les éléments horizontalement
            children: [
              Text(
                "Retrait",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text("Compte de virement"),
              // Regrouper les images avec un espacement réduit
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8), // Coins arrondis
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center, // Centrer les images horizontalement
                  children: [
                    _buildImage('assets/images/American Express.png'),
                    SizedBox(width: 10), // Espacement réduit entre les images
                    _buildImage('assets/images/Visa.png'),
                    SizedBox(width: 10),
                    _buildImage('assets/images/American Express.png'),
                    SizedBox(width: 10),
                    _buildImage('assets/images/Discover.png'),
                  ],
                ),
              ),
              SizedBox(height: 30),
              _buildTextField("Nom sur la carte", "Rencontrez Patel"),
              SizedBox(height: 35),
              _buildTextField("Numéro de carte", "0000 0000 0000 0000"),
              SizedBox(height: 35),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown("Mois", ["01", "02", "03", "04"]),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown("Année", ["2024", "2025", "2026"]),
                  ),
                ],
              ),
              SizedBox(height: 35),
              _buildTextField(
                "Code de sécurité de la carte",
                "Code",
                obscureText: true,
              ),
              SizedBox(height: 30),
              // Le bouton est dans un conteneur rectangulaire sans bord arrondi
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xfff8bf13), // Couleur du fond du bouton
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0Xfff8bf13),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.zero, // Enlever les coins arrondis
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MesRetraitsPage(),
                        ), // Navigation vers la page MesRetraitsPage
                      );
                    },
                    child: Text(
                      "Demander Un Retrait",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
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
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  // Widget pour le menu déroulant
  Widget _buildDropdown(String hint, List<String> items) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: hint, // Le texte du label est en dehors du champ
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      items:
          items
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
