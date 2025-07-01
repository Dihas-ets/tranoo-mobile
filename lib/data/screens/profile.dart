import 'dart:io'; // Pour manipuler les fichiers images

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importer la bibliothèque pour la sélection d'image

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
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
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    // Calcul des dimensions adaptatives
    final avatarRadius = screenWidth * (isPortrait ? 0.15 : 0.1);
    final fontSize = screenWidth * (isPortrait ? 0.04 : 0.03);
    final spacing = screenHeight * (isPortrait ? 0.02 : 0.03);
    final padding = screenWidth * (isPortrait ? 0.05 : 0.1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mon compte",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize * 1.2,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage:
                      _image != null
                          ? FileImage(_image!)
                          : const AssetImage("assets/images/jenifer.jpg")
                              as ImageProvider,
                  child:
                      _image == null
                          ? Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: avatarRadius * 0.5,
                          )
                          : null,
                ),
              ),
              SizedBox(height: spacing),
              Text(
                "Itunuoluwa Abidoye",
                style: TextStyle(
                  fontSize: fontSize * 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "itunuoluwa@petra.africa",
                style: TextStyle(color: Colors.grey, fontSize: fontSize),
              ),
              SizedBox(height: spacing * 2),
              _buildProfileSection(
                context,
                title: "Informations personnelles",
                items: [
                  _buildProfileItem(
                    context,
                    icon: Icons.person,
                    label: "Nom complet",
                    value: "Itunuoluwa Abidoye",
                  ),
                  _buildProfileItem(
                    context,
                    icon: Icons.email,
                    label: "Email",
                    value: "itunuoluwa@petra.africa",
                  ),
                  _buildProfileItem(
                    context,
                    icon: Icons.phone,
                    label: "Téléphone",
                    value: "+229 12345678",
                  ),
                ],
              ),
              SizedBox(height: spacing * 2),
              _buildProfileSection(
                context,
                title: "Sécurité",
                items: [
                  _buildProfileItem(
                    context,
                    icon: Icons.lock,
                    label: "Mot de passe",
                    value: "********",
                    showEdit: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final fontSize = screenWidth * (isPortrait ? 0.04 : 0.03);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize * 1.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 25),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool showEdit = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final fontSize = screenWidth * (isPortrait ? 0.04 : 0.03);
    final iconSize = screenWidth * (isPortrait ? 0.06 : 0.04);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: Colors.grey),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (showEdit)
            IconButton(
              icon: Icon(Icons.edit, size: iconSize * 0.8, color: Colors.grey),
              onPressed: () {
                // TODO: Implémenter l'édition
              },
            ),
        ],
      ),
    );
  }
}
