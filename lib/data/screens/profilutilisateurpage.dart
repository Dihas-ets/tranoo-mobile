import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/data/screens/WalletScreen.dart';
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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
        title: const Text("Profil utilisateur", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
            const Text("Plus", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        color: Color(0xFFF8BF13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : const AssetImage("assets/images/avatar.png") as ImageProvider,
              child: _image == null ? const Icon(Icons.camera_alt, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Itunuoluwa Abidoye", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("abidoye@itunuakwa", style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          _buildListTile("Mon compte", Icons.person, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
          }),
          _buildListTile("Vendre ma voiture", Icons.car_rental),
          _buildListTile("Devenir chauffeur certifié", Icons.delivery_dining),
          _buildListTile("Mon portefeuille", Icons.account_balance_wallet, trailing: const Text("200000 XOF", style: TextStyle(fontWeight: FontWeight.bold)), onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletScreen()));
          }),
          _buildListTile("Déconnexion", Icons.logout, color: Colors.red),
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
          _buildOption("Notifications", "", Icons.notifications, badge: true),
          _buildOption("Langue", selectedLanguage, Icons.language, trailing: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => _showLanguageDialog(context))),
          _buildOption("Devise", "XOF", Icons.monetization_on),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, {Color color = Colors.black, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildOption(String title, String value, IconData icon, {bool badge = false, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      trailing: trailing ?? (badge ? const Icon(Icons.circle, size: 12, color: Colors.red) : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black)),
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
              for (var lang in ["Français", "Anglais", "Espagnol", "Allemand", "Italien"])
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
}
