import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/data/screens/wallet_screen.dart';
import 'package:tranoo/data/screens/connexion_page.dart';
import 'package:tranoo/data/screens/create_sell.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/profile.dart';
import 'package:tranoo/data/screens/create_sell2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/cloudinary_upload.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfilUtilisateurPage(),
    );
  }
}

class ProfilUtilisateurPage extends StatefulWidget {
  const ProfilUtilisateurPage({super.key});

  @override
  ProfilUtilisateurPageState createState() => ProfilUtilisateurPageState();
}

class ProfilUtilisateurPageState extends State<ProfilUtilisateurPage> {
  File? _image;
  String selectedLanguage = "Français";
  String selectedCurrencyValue = "XOF";
  Map<String, dynamic>? userData;
  bool loading = true;
  String? errorMsg;
  double? _walletBalance;
  String _walletCurrency = "XOF";
  bool _walletLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
    _loadWallet();
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

  Future<void> _loadWallet() async {
    setState(() {
      _walletLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _walletLoading = false;
          _walletBalance = null;
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
      final res = await dio.get('/wallet/me');
      setState(() {
        _walletBalance = (res.data['balance'] ?? 0).toDouble();
        _walletCurrency = (res.data['currency'] ?? 'XOF').toString();
        selectedCurrencyValue = _walletCurrency;
        _walletLoading = false;
      });
    } catch (e) {
      setState(() {
        _walletLoading = false;
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

    try {
      // Upload vers Cloudinary avec le dossier profiles
      final url = await uploadImageToCloudinary(
        image,
        folder: CloudinaryFolders.profiles,
      );

      if (url != null) {
        // Mettre à jour via PATCH /users/me
        final idToken = await user.getIdToken();
        final String baseUrl = getBaseUrl();
        final dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {'Authorization': 'Bearer $idToken'},
          ),
        );
        await dio.patch('/users/me', data: {"photo": url});
        setState(() {
          userData?["photo"] = url;
        });
      }
    } catch (e) {
      print('Erreur upload photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());
    if (errorMsg != null) return Center(child: Text(errorMsg!));
    if (userData == null) {
      return Center(child: Text("Aucune donnée utilisateur"));
    }
    if (userData != null && userData?['role'] != 'vendeur') {
      return Center(child: Text("Accès réservé aux vendeurs."));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil utilisateur",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            // Profile card dynamique
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8BF13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _image != null
                              ? FileImage(_image!) as ImageProvider
                              : (userData != null &&
                                      userData!["photo"] != null &&
                                      userData!["photo"].toString().isNotEmpty)
                                  ? NetworkImage(userData!["photo"].toString())
                                      as ImageProvider
                                  : null,
                          child: (_image == null &&
                                  (userData == null ||
                                      userData!["photo"] == null ||
                                      userData!["photo"].toString().isEmpty))
                              ? Icon(Icons.person,
                                  size: 30, color: Colors.grey[600])
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: -5,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData?["nom"] ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        userData?["email"] ?? "",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            _buildAccountOptions(),
            const SizedBox(height: 20),
            const Text(
              "Plus",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildMoreOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Color(0xFFFFCE31)),
      title: Text(title, style: const TextStyle()),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildAccountOptions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildListTile(
            title: "Mon compte",
            subtitle: "Apporter des modifications à votre compte",
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
          _buildListTile(
            title: "Vendre ma voiture",
            subtitle: "Devenir titulaire et vendez avec nous",
            icon: Icons.car_rental,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateSellPage()),
              );
            },
          ),
          _buildListTile(
            title: "Vendre ma pièce",
            subtitle: "Devenir titulaire et vendez avec nous",
            icon: Icons.build,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateSellPage2()),
              );
            },
          ),
          _buildListTile(
            title: "Mon portefeuille",
            icon: Icons.account_balance_wallet,
            trailing: _walletLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _walletBalance == null
                        ? '--'
                        : '${_walletCurrency} ${_walletBalance!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              );
            },
          ),
          _buildListTile(
            title: "Déconnexion",
            icon: Icons.logout,
            color: Color(0xFFFFCE31),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnexionPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          _buildOption(
            "Notifications",
            "",
            Icons.notifications,
            badge: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Notifications()),
              );
            },
          ),
          _buildOption(
            "Langue",
            selectedLanguage,
            Icons.language,
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _showLanguageDialog(context),
            ),
          ),
          _buildOption(
            "Devise",
            selectedCurrencyValue,
            Icons.monetization_on,
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _showCurrencyDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    String title,
    String value,
    IconData icon, {
    bool badge = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFFFFCE31)),
      title: Row(
        children: [
          Text(title, style: const TextStyle()),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      trailing: trailing ??
          (badge
              ? const Icon(Icons.circle, size: 12, color: Colors.red)
              : const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.black,
                )),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var lang in [
                "Français",
                "Anglais",
                "Espagnol",
                "Allemand",
                "Italien",
              ])
                ListTile(
                  title: Text(lang),
                  onTap: () {
                    setState(() {
                      selectedLanguage = lang;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une devise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('XOF'),
                onTap: () {
                  Navigator.pop(context, 'XOF');
                },
              ),
              ListTile(
                title: const Text('Euro'),
                onTap: () {
                  Navigator.pop(context, 'Euro');
                },
              ),
              ListTile(
                title: const Text('Dollars'),
                onTap: () {
                  Navigator.pop(context, 'Dollars');
                },
              ),
            ],
          ),
        );
      },
    ).then((selectedCurrency) {
      if (selectedCurrency != null) {
        setState(() {
          selectedCurrencyValue = selectedCurrency;
        });
      }
    });
  }
}
