// ignore_for_file: unused_local_variable

import 'dart:io'; // Pour manipuler les fichiers images

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importer la bibliothèque pour la sélection d'image
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/cloudinary_upload.dart'; // Importer le composant d'upload Cloudinary
import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as local_auth;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? selectedGender;
  String? selectedCountry;
  File? _image; // Pour stocker l'image sélectionnée
  Map<String, dynamic>? userData;
  bool loading = true;
  String? errorMsg;

  // Ajout pour édition dynamique
  bool isEditingName = false;
  bool isEditingEmail = false;
  bool isEditingPhone = false;
  bool isEditingPassword = false;
  String? editedName;
  String? editedEmail;
  String? editedPhone;
  String? newPassword;
  bool isSaving = false;

  final List<Map<String, String>> countries = [
    {"name": "Bénin", "flag": "assets/flags/benin.svg"},
    {"name": "France", "flag": "assets/flags/france.svg"},
    {"name": "USA", "flag": "assets/flags/usa.svg"},
    {"name": "Canada", "flag": "assets/flags/canada.svg"},
  ];

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
      final String baseUrl = getBaseUrl();
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
        editedName = userData?["nom"] ?? "";
        editedEmail = userData?["email"] ?? "";
        editedPhone = userData?["telephone"] ?? "";
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

  // Fonction pour choisir une image depuis la galerie et upload Cloudinary
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Upload Cloudinary
      final url = await uploadImageToCloudinary(
        _image!,
        folder: CloudinaryFolders.profiles,
      );
      if (url != null) {
        await _uploadPhotoUrl(url);
      }
    }
  }

  // Met à jour la photo de profil avec l'URL Cloudinary
  Future<void> _uploadPhotoUrl(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();
    final String baseUrl = getBaseUrl();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );
    await dio.patch('/users/me', data: {"photo": url});
    final me = await dio.get('/protected/me');
    final refreshedUser = me.data['user'];
    await local_auth.AuthProvider.saveUserToPrefs(idToken, refreshedUser);
    if (mounted) {
      context.read<local_auth.AuthProvider>().reloadUser();
      setState(() {
        userData?['photo'] = url;
      });
    }
  }

  // Edition des infos utilisateur
  Future<void> _saveProfileField(String field, String value) async {
    setState(() {
      isSaving = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();
    final String baseUrl = getBaseUrl();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );
    await dio.patch('/users/me', data: {field: value});
    // Après modification, on resynchronise toutes les données
    await fetchUser();
    setState(() {
      isSaving = false;
      isEditingName = false;
      isEditingEmail = false;
      isEditingPhone = false;
    });
  }

  // Edition du mot de passe
  Future<void> _savePassword() async {
    if (newPassword == null || newPassword!.length < 6) return;
    setState(() {
      isSaving = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final idToken = await user.getIdToken();
    final String baseUrl = getBaseUrl();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );
    final role = userData?['role']?.toString();
    final int minLen = role == 'admin' ? 11 : 6;
    if (newPassword == null || newPassword!.length < minLen) {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Le mot de passe doit contenir au moins ${minLen.toString()} caractères.',
          ),
        ),
      );
      return;
    }
    await dio.patch('/users/password', data: {"newPassword": newPassword});
    setState(() {
      isEditingPassword = false;
      isSaving = false;
      newPassword = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mot de passe modifié avec succès.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final spacing = screenHeight * (isPortrait ? 0.02 : 0.03);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Compte",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          loading
              ? _buildProfileSkeleton(context)
              : errorMsg != null
              ? Center(child: Text(errorMsg!))
              : userData == null
              ? Center(child: Text("Aucune donnée utilisateur"))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  _image != null
                                      ? FileImage(_image!) as ImageProvider
                                      : (userData != null &&
                                          userData!["photo"] != null &&
                                          userData!["photo"]
                                              .toString()
                                              .isNotEmpty)
                                      ? NetworkImage(userData!["photo"].toString()) as ImageProvider
                                      : null,
                              child: (_image == null && 
                                      (userData == null || 
                                       userData!["photo"] == null || 
                                       userData!["photo"].toString().isEmpty))
                                  ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Nom / Email / Téléphone (mode lecture ou édition groupée)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                isEditingName
                                    ? TextField(
                                        autofocus: true,
                                        onChanged: (v) => editedName = v,
                                        controller: TextEditingController(
                                          text: editedName,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: "Nom complet",
                                        ),
                                      )
                                    : Text(
                                        userData?["nom"] ?? "",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                const SizedBox(height: 4),
                                isEditingName
                                    ? TextField(
                                        onChanged: (v) => editedEmail = v,
                                        controller: TextEditingController(
                                          text: editedEmail,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: "Email",
                                        ),
                                      )
                                    : Text(
                                        userData?["email"] ?? "",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                const SizedBox(height: 4),
                                isEditingName
                                    ? TextField(
                                        onChanged: (v) => editedPhone = v,
                                        controller: TextEditingController(
                                          text: editedPhone,
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: "Téléphone",
                                        ),
                                      )
                                    : Text(
                                        userData?["telephone"] ?? "",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isEditingName ? Icons.close : Icons.edit,
                            ),
                            onPressed: () {
                              setState(() {
                                if (isEditingName) {
                                  isEditingName = false;
                                  editedName = userData?["nom"] ?? "";
                                  editedEmail = userData?["email"] ?? "";
                                  editedPhone = userData?["telephone"] ?? "";
                                } else {
                                  isEditingName = true;
                                  editedName = userData?["nom"] ?? "";
                                  editedEmail = userData?["email"] ?? "";
                                  editedPhone = userData?["telephone"] ?? "";
                                }
                              });
                            },
                          ),
                          if (isEditingName)
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Color(0xFFF8BF13),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if ((editedName ?? '').trim().isEmpty ||
                                          (editedEmail ?? '').trim().isEmpty ||
                                          (editedPhone ?? '').trim().isEmpty) {
                                        return;
                                      }
                                      setState(() => isSaving = true);
                                      await _saveProfileField(
                                        "nom",
                                        editedName!.trim(),
                                      );
                                      await _saveProfileField(
                                        "email",
                                        editedEmail!.trim(),
                                      );
                                      await _saveProfileField(
                                        "telephone",
                                        editedPhone!.trim(),
                                      );
                                      setState(() {
                                        isSaving = false;
                                        isEditingName = false;
                                      });
                                    },
                            ),
                        ],
                      ),
                      SizedBox(height: spacing * 2),
                      // Section informations personnelles (readonly)
                      _buildProfileSection(
                        context,
                        title: "Informations personnelles",
                        items: [
                          _buildProfileItem(
                            context,
                            icon: Icons.person,
                            label: "Nom complet",
                            value: "********",
                          ),
                          _buildProfileItem(
                            context,
                            icon: Icons.email,
                            label: "Email",
                            value: "********",
                          ),
                          _buildProfileItem(
                            context,
                            icon: Icons.phone,
                            label: "Téléphone",
                            value: "********",
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
                            showEdit: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileSkeleton(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final spacing = screenHeight * (isPortrait ? 0.02 : 0.03);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 60, backgroundColor: Colors.grey[300]),
          const SizedBox(height: 20),
          Container(height: 24, width: 120, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Container(height: 18, width: 180, color: Colors.grey[200]),
          const SizedBox(height: 10),
          Container(height: 18, width: 140, color: Colors.grey[200]),
          SizedBox(height: spacing * 2),
          Container(height: 18, width: 200, color: Colors.grey[200]),
          SizedBox(height: spacing * 2),
          Container(height: 18, width: 200, color: Colors.grey[200]),
        ],
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
          Icon(icon, size: iconSize, color: Colors.grey[700]),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    color: Colors.grey[600],
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
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}