import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/data/screens/WalletScreen.dart';
import 'package:tranoo/data/screens/connexion_page.dart';
import 'package:tranoo/data/screens/create_sell.dart';
import 'package:tranoo/data/screens/driver_certified.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/profile.dart';

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
  _ProfilUtilisateurPageState createState() => _ProfilUtilisateurPageState();
}

class _ProfilUtilisateurPageState extends State<ProfilUtilisateurPage> {
  File? _image;
  String selectedLanguage = "Français";
  String selectedCurrencyValue = "XOF"; // Valeur de devise par défaut

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
            _buildProfileCard(),
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

  Widget _buildProfileCard() {
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
                          : const AssetImage("assets/images/jenifer.jpg")
                              as ImageProvider,
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
            children: const [
              Text(
                "Itunuoluwa Abidoye",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text("abidoye@itunuakwa", style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
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
            title: "Devenir chauffeur certifié",
            subtitle: "Proposer des services de livraison",
            icon: Icons.delivery_dining,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriverCertifiedPage()),
              );
            },
          ),
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
