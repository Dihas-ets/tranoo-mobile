import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';

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
  bool isSaving = false;

  // Controllers pour champs dynamiques
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _entrepriseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  // Password
  final TextEditingController _newPasswordController = TextEditingController();
  bool _showNewPassword = false;

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
        _nomController.text = userData?["nom"] ?? "";
        _entrepriseController.text = userData?["entreprise"] ?? "";
        _emailController.text = userData?["email"] ?? "";
        _telephoneController.text = userData?["telephone"] ?? "";
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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
        baseUrl: getBaseUrl(),
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
    if (userData != null && userData?['role'] != 'transitaire') {
      return Center(child: Text("Accès réservé aux transitaires."));
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

              // Champs dynamiques
              _buildTextField(
                controller: _nomController,
                hintText: "Nom complet",
                fontSize: fontSize,
              ),
              SizedBox(height: spacing),
              _buildTextField(
                controller: _entrepriseController,
                hintText: "Entreprise",
                fontSize: fontSize,
              ),
              SizedBox(height: spacing),
              _buildTextField(
                controller: _emailController,
                hintText: "Email",
                fontSize: fontSize,
              ),
              SizedBox(height: spacing),
              _buildTextField(
                controller: _telephoneController,
                hintText: "Téléphone",
                fontSize: fontSize,
              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required double fontSize,
  }) {
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
        controller: controller,
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
        controller: _newPasswordController,
        style: TextStyle(fontSize: fontSize),
        obscureText: !_showNewPassword,
        decoration: InputDecoration(
          hintText: "Nouveau mot de passe",
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: fontSize,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.grey,
            size: fontSize * 1.2,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _showNewPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.amber,
              size: fontSize * 1.2,
            ),
            onPressed: () {
              setState(() {
                _showNewPassword = !_showNewPassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      isSaving = true;
    });
    final idToken = await user.getIdToken();
    final String baseUrl = getBaseUrl();
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Authorization': 'Bearer $idToken'},
      ),
    );

    final Map<String, dynamic> data = {
      'nom': _nomController.text.trim(),
      'entreprise': _entrepriseController.text.trim(),
      'email': _emailController.text.trim(),
      'telephone': _telephoneController.text.trim(),
    };

    try {
      await dio.patch('/users/me', data: data);
      // Mot de passe si fourni (nouveau seulement) avec validation minimale
      final role = userData?['role']?.toString();
      final int minLen = role == 'admin' ? 11 : 6;
      final newPwd = _newPasswordController.text;
      if (newPwd.isNotEmpty) {
        if (newPwd.length < minLen) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Le mot de passe doit contenir au moins ${minLen.toString()} caractères.',
                ),
              ),
            );
          }
        } else {
          await dio.patch('/users/password', data: {'newPassword': newPwd});
          _newPasswordController.clear();
          setState(() {
            _showNewPassword = false;
          });
        }
      }
      await fetchUser();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil mis à jour.')));
      }
    } on DioError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data?['message']?.toString() ??
                  'Erreur lors de la mise à jour',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildUpdateButton(BuildContext context, double fontSize) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF8BF13),
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: fontSize * 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          isSaving ? "Enregistrement..." : "Mettre à jour le profil",
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}