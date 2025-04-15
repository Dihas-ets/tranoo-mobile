import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile2 extends StatefulWidget {
  const Profile2({super.key});

  @override
  State<Profile2> createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  File? _image;
  String? selectedGender = "Mâle";
  String? selectedCountry = "Mali";

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
                "Itunuoluwa abidoye",
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

              // Formulaire simple
              _buildTextField("Isaac mobiya"),
              SizedBox(height: spacing),

              _buildTextField("Transit Inter SARL"),
              SizedBox(height: spacing),

              _buildCountryDropdown(),
              SizedBox(height: spacing),

              _buildGenderDropdown(),
              SizedBox(height: spacing),

              _buildPasswordField(),
              SizedBox(height: spacing * 2),

              _buildUpdateButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Image.asset(
              "assets/images/mali.png",
              width: 24,
              height: 16,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.flag, size: 24);
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCountry,
                  hint: const Text("Pays"),
                  isExpanded: true,
                  items:
                      ["Bénin", "Gabon", "Mali", "Canada"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCountry = newValue;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedGender,
            hint: const Text("Genre"),
            isExpanded: true,
            items:
                ["Mâle", "Femelle", "Autre"].map((String value) {
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
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Changer son mot de passe",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.lock, color: Colors.amber),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          "Mettre à jour le profil",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
