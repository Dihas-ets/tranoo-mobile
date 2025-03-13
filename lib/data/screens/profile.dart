import 'dart:io'; // Pour manipuler les fichiers images

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart'; // Importer la bibliothèque pour la sélection d'image

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? selectedGender;
  String? selectedCountry;
  File? _image; // Pour stocker l'image sélectionnée

  final List<Map<String, String>> countries = [
    {"name": "Bénin", "flag": "assets/flags/benin.svg"},
    {"name": "France", "flag": "assets/flags/france.svg"},
    {"name": "USA", "flag": "assets/flags/usa.svg"},
    {"name": "Canada", "flag": "assets/flags/canada.svg"},
  ];

  // Fonction pour choisir une image depuis la galerie
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Met à jour l'image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mon compte",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Mettre en gras
            fontSize: 20, // Réduire la taille du texte
            color: Colors.black,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap:
                  _pickImage, // Quand on clique sur le cercle, on choisit une image
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    _image != null
                        ? FileImage(_image!)
                        : AssetImage("assets/person_icon.png")
                            as ImageProvider, // Utilise l'image choisie ou une icône par défaut
                child:
                    _image == null
                        ? Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 30,
                        ) // Icône de caméra si pas d'image
                        : null,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Itunuoluwa Abidoye",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "itunuoluwa@petra.africa",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Quel est votre prénom?",
                border: InputBorder.none, // Bordure invisible
                filled: true,
                fillColor: Colors.white, // Fond blanc
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Et votre nom de famille?",
                border: InputBorder.none, // Bordure invisible
                filled: true,
                fillColor: Colors.white, // Fond blanc
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Société",
                border: InputBorder.none, // Bordure invisible
                filled: true,
                fillColor: Colors.white, // Fond blanc
              ),
              items:
                  countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country["name"],
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            country["flag"]!,
                            width: 24, // Ajuste la taille des drapeaux
                            height: 16,
                          ),
                          SizedBox(width: 10),
                          Text(country["name"]!),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCountry = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Sélectionnez votre sexe",
                border: InputBorder.none, // Bordure invisible
                filled: true,
                fillColor: Colors.white, // Fond blanc
              ),
              items:
                  ["Homme", "Femme", "Autre"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedGender = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Changer son mot de passe",
                border: InputBorder.none, // Bordure invisible
                suffixIcon: Icon(
                  Icons.lock,
                  color: Color(0xFFF8BF13), // Couleur de l'icône en jaune
                ),
                filled: true,
                fillColor: Colors.white, // Fond blanc
              ),
              obscureText: true,
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF8BF13), // Fond jaune
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50), // Longueur plus grande
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "Mettre à jour le profil",
                  style: TextStyle(color: Colors.black), // Texte noir
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
