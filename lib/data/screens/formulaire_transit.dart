import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'historique_transit.dart'; // Importez la page HistoriqueTransitPage

class FormulaireTransitPage extends StatefulWidget {
  const FormulaireTransitPage({super.key});

  @override
  State<FormulaireTransitPage> createState() => _FormulaireTransitPageState();
}

class _FormulaireTransitPageState extends State<FormulaireTransitPage> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _voitureController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _portDepartController = TextEditingController();
  final TextEditingController _portArriveeController = TextEditingController();
  final TextEditingController _dateTransitController = TextEditingController();
  final TextEditingController _statutController = TextEditingController();

  // Liste des fichiers téléchargés
  final List<File> _documents = [];

  // Fonction pour sélectionner un fichier
  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _documents.add(File(pickedFile.path));
      });
    }
  }

  // Fonction pour soumettre le formulaire
  void _submitForm() {
    // Ajoutez ici la logique pour mettre à jour les données dans historique_transit
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoriqueTransitPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Formulaires de transit",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ "Nom de la voiture"
            _buildTextField(
              controller: _voitureController,
              label: "Nom de la voiture",
              hintText: "Toyota Corolla 2018",
            ),
            const SizedBox(height: 16),

            // Champ "Client"
            _buildTextField(
              controller: _clientController,
              label: "Client",
              hintText: "Marcel T",
            ),
            const SizedBox(height: 16),

            // Champ "Port de départ"
            _buildTextField(
              controller: _portDepartController,
              label: "Port de départ",
              hintText: "Anvers, Belgique",
            ),
            const SizedBox(height: 16),

            // Champ "Port d'arrivée"
            _buildTextField(
              controller: _portArriveeController,
              label: "Port d'arrivée",
              hintText: "Cotonou, Bénin",
            ),
            const SizedBox(height: 16),

            // Champ "Date de transit"
            _buildTextField(
              controller: _dateTransitController,
              label: "Date de transit",
              hintText: "10 avril 2025",
            ),
            const SizedBox(height: 16),

            // Champ "Statut"
            _buildTextField(
              controller: _statutController,
              label: "Statut",
              hintText: "En transit",
            ),
            const SizedBox(height: 24),

            // Section pour télécharger les documents
            Center(
              child: Column(
                children: [
                  IconButton(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                  const Text(
                    "Télécharger les documents",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Liste des documents téléchargés
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _documents.map((file) {
                return GestureDetector(
                  onTap: () {
                    // Action pour ouvrir le fichier
                  },
                  child: Text(
                    file.path.split('/').last,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Bouton "Soumettre"
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Soumettre",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour construire un champ de texte
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              " *",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: const UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }
}