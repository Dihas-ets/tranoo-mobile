import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class Profile2 extends StatefulWidget {
  const Profile2({super.key});

  @override
  State<Profile2> createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  File? _image;
  String? selectedGender = "Mâle";
  String? selectedCountry = "Mali";
  Map<String, dynamic>? userData;
  bool loading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          loading = false;
          userData = null;
          errorMsg = "Utilisateur non connecté.";
        });
        return;
      }
      final idToken = await user.getIdToken();
      final String baseUrl = 'https://api.tranoo.store/api';

      // final String baseUrl =
      //     kIsWeb
      //         ? 'http://localhost:5000/api'
      //         : (Platform.isAndroid
      //             ? 'http://10.0.2.2:5000/api'
      //             : 'http://192.168.100.21:5000/api');
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );
      final response = await dio.get('/protected/me');
      setState(() {
        userData = response.data['user'];
        loading = false;
        errorMsg = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        userData = null;
        errorMsg =
            "Impossible de charger le profil. Vérifiez votre connexion ou vos droits.";
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadPhoto(_image!);
    }
  }

  Future<void> _uploadPhoto(File image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:5000/api',
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );
    FormData formData = FormData.fromMap({
      "photo": await MultipartFile.fromFile(
        image.path,
        filename: "profile.jpg",
      ),
    });
    final response = await dio.post('/users/photo', data: formData);
    setState(() {
      userData?["photo"] = response.data["photo"];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());
    if (errorMsg != null) return Center(child: Text(errorMsg!));
    if (userData == null)
      return Center(child: Text("Aucune donnée utilisateur"));
    if (userData != null && userData?['role'] != 'vendeur') {
      return Center(child: Text("Accès réservé aux vendeurs."));
    }
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
                          : (userData != null &&
                              userData!["photo"] != null &&
                              userData!["photo"].toString().isNotEmpty)
                          ? NetworkImage(userData!["photo"])
                          : const AssetImage("assets/images/jenifer.jpg")
                              as ImageProvider,
                  child:
                      _image == null
                          ? Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: fontSize * 1.5,
                          )
                          : null,
                ),
              ),
              SizedBox(height: spacing * 2),
              Text(
                userData?["nom"] ?? "",
                style: TextStyle(
                  fontSize: fontSize * 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userData?["email"] ?? "",
                style: TextStyle(color: Colors.grey, fontSize: fontSize),
              ),
              SizedBox(height: spacing * 2),

              // Formulaire simple
              _buildTextField("Isaac mobiya", fontSize),
              SizedBox(height: spacing),

              _buildTextField("Transit Inter SARL", fontSize),
              SizedBox(height: spacing),

              _buildCountryDropdown(fontSize),
              SizedBox(height: spacing),

              _buildGenderDropdown(fontSize),
              SizedBox(height: spacing),

              _buildPasswordField(fontSize),
              SizedBox(height: spacing * 2),

              _buildUpdateButton(context, fontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, double fontSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              Colors.grey.r.toInt(),
              Colors.grey.g.toInt(),
              Colors.grey.b.toInt(),
              0.1,
            ),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: fontSize,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCountryDropdown(double fontSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              Colors.grey.r.toInt(),
              Colors.grey.g.toInt(),
              Colors.grey.b.toInt(),
              0.1,
            ),
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
                  hint: Text("Pays", style: TextStyle(fontSize: fontSize)),
                  isExpanded: true,
                  items:
                      ["Bénin", "Gabon", "Mali", "Canada"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: fontSize),
                          ),
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

  Widget _buildGenderDropdown(double fontSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              Colors.grey.r.toInt(),
              Colors.grey.g.toInt(),
              Colors.grey.b.toInt(),
              0.1,
            ),
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
            hint: Text("Genre", style: TextStyle(fontSize: fontSize)),
            isExpanded: true,
            items:
                ["Mâle", "Femelle", "Autre"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: fontSize)),
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

  Widget _buildPasswordField(double fontSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              Colors.grey.r.toInt(),
              Colors.grey.g.toInt(),
              Colors.grey.b.toInt(),
              0.1,
            ),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(fontSize: fontSize),
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Changer son mot de passe",
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: fontSize,
          ),
          border: InputBorder.none,
          suffixIcon: Icon(
            Icons.lock,
            color: Colors.amber,
            size: fontSize * 1.2,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.grey,
            size: fontSize * 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context, double fontSize) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: fontSize * 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          "Mettre à jour le profil",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
