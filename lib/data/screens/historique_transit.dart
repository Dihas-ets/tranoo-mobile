import 'package:flutter/material.dart';
import 'formulaire_transit.dart'; // Importez la page formulaire_transit.dart

class HistoriqueTransitPage extends StatelessWidget {
  const HistoriqueTransitPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste des transits
    final List<Map<String, dynamic>> transits = [
      {
        "voiture": "Toyota Corolla 2018",
        "client": "Marcel T.",
        "portDepart": "Anvers, Belgique",  
        "portArrivee": "Cotonou, Bénin",
        "dateTransit": "10 avril 2025",
        "statut": "Livré avec succès",
        "statutCouleur": Colors.green,
        "documents": [
          "Connaissement",
          "Facture Proforma",
          "Certificat de transit"
        ],
        "couleurFond": Colors.yellow[100],
      },
      {
        "voiture": "BMW X5 2020",
        "client": "CarExpert Auto",
        "portDepart": "Hambourg, Allemagne",
        "portArrivee": "Lomé, Togo",
        "dateTransit": "25 mars 2025",
        "statut": "En transit",
        "statutCouleur": Colors.blue,
        "documents": [
          "Connaissement",
          "Attestation de dédouanement partiel"
        ],
        "couleurFond": Colors.blue[100],
      },
      {
        "voiture": "Kia Picanto 2016",
        "client": "Aline K.",
        "portDepart": "Le Havre, France",
        "portArrivee": "Cotonou, Bénin",
        "dateTransit": "15 mars 2025",
        "statut": "En douane",
        "statutCouleur": Colors.orange,
        "documents": [
          "Facture Proforma",
          "Certificat d'inspection"
        ],
        "couleurFond": Colors.green[100],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Historiques des transits",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue, size: 24),
              onPressed: () {
                // Redirection vers la page formulaire_transit.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormulaireTransitPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transits.length,
        itemBuilder: (context, index) {
          final transit = transits[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transit["couleurFond"],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transit["voiture"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Client : ${transit["client"]}"),
                Text("Port de départ : ${transit["portDepart"]}"),
                Text("Port d'arrivée : ${transit["portArrivee"]}"),
                Text("Date de transit : ${transit["dateTransit"]}"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Statut : ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      transit["statut"],
                      style: TextStyle(
                        color: transit["statutCouleur"],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: transit["documents"].map<Widget>((doc) {
                    return GestureDetector(
                      onTap: () {
                        // Action pour ouvrir le document
                      },
                      child: Text(
                        doc,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}