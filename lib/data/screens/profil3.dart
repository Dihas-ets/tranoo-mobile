import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/data/screens/wallet_screen.dart';
import 'package:tranoo/data/screens/connexion_page.dart';
import 'package:tranoo/data/screens/mesachats.dart';
import 'package:tranoo/data/screens/mesavis.dart';
import 'package:tranoo/data/screens/mesfactures.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/profile.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Profil3(),
    );
  }
}

class Profil3 extends StatefulWidget {
  const Profil3({super.key});

  @override
  Profil3State createState() => Profil3State();
}

class Profil3State extends State<Profil3> {
  File? _image;
  String selectedLanguage = "Français";
  String selectedCurrencyValue = "XOF";
  // SUPPRIME : Map<String, dynamic>? userData;
  // SUPPRIME : bool loading = true;
  // SUPPRIME : String? errorMsg;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<myauth.AuthProvider>(context);
    final userData = authProvider.user;
    final loading = authProvider.loading;
    final errorMsg =
        userData == null && !loading ? "Utilisateur non connecté." : null;

    if (loading) return Center(child: CircularProgressIndicator());
    if (errorMsg != null) return Center(child: Text(errorMsg));
    if (userData == null) {
      return Center(child: Text("Aucune donnée utilisateur"));
    }
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     "Profil utilisateur",
      //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      //   ),
      //   foregroundColor: Colors.black,
      //   elevation: 0,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            _buildProfileCard(userData),
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

  Widget _buildProfileCard(Map<String, dynamic> userData) {
    final hasPhoto =
        userData["photo"] != null && userData["photo"].toString().isNotEmpty;
    return Container(
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
                  backgroundImage:
                      _image != null
                          ? FileImage(_image!)
                          : hasPhoto
                          ? NetworkImage(userData["photo"]) as ImageProvider
                          : const AssetImage("assets/images/jenifer.jpg"),
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
                userData["nom"] ?? "",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                userData["email"] ?? "",
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Ici, tu peux ajouter l'upload si besoin
    }
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
      subtitle:
          subtitle != null
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

          // _buildListTile(
          //   title: "Mes achats",
          //   subtitle: "Voir l'historique de vos commandes",
          //   icon: Icons.history,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => MesAchatsPage()),
          //     );
          //   },
          // ),
          // _buildListTile(
          //   title: "Mes avis",
          //   subtitle: "Consulter ou modifier vos commentaires",
          //   icon: Icons.reviews,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => MesAvisPage()),
          //     );
          //     // Rediriger vers une page des avis
          //   },
          // ),
          // _buildListTile(
          //   title: "Mes factures",
          //   subtitle: "Télécharger vos justificatifs d'achats",
          //   icon: Icons.receipt_long,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => MesFacturesPage()),
          //     );
          //   },
          // ),

          _buildListTile(
            title: "Mon portefeuille",
            icon: Icons.account_balance_wallet,
            trailing: Text(
              "200000 $selectedCurrencyValue",
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
            onTap: () async {
              await Provider.of<myauth.AuthProvider>(
                context,
                listen: false,
              ).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ConnexionPage()),
                (route) => false,
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
      trailing:
          trailing ??
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