import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/data/screens/WalletScreen.dart';
import 'package:tranoo/data/screens/conditionutilisations.dart';
import 'package:tranoo/data/screens/marque.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/profilutilisateurpage.dart';
import 'package:tranoo/data/screens/recherche.dart';
import 'package:tranoo/data/screens/vendre.dart';
import 'package:tranoo/languesentreprise.dart';

import 'connexion_page.dart';

class AvantHome extends StatefulWidget {
  const AvantHome({super.key});

  @override
  State<AvantHome> createState() => _AvantHomeState();
}

class _AvantHomeState extends State<AvantHome> {
  int _selectedIndex = 0;
  File? _image; // Variable pour stocker l'image sélectionnée

  // Ajout du GlobalKey pour le Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [Marque(), Recherche(), Vendre(), Piece()];

  // Méthode pour sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        toolbarHeight: 70,
        title: Center(
          child: Image.asset("assets/images/logo_connexion.png", height: 32),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.black,
                  size: 32,
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF8BF13),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notifications()),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 32),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Ouvre le Drawer ici
          },
        ),
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Color(0XffF8BF13)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap:
                          _pickImage, // Ouvre la galerie quand l'avatar est cliqué
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.15,
                        backgroundColor:
                            Colors.grey, // Ajout d'une couleur de fond
                        backgroundImage:
                            _image == null
                                ? const AssetImage("assets/images/jenifer.jpg")
                                : FileImage(_image!) as ImageProvider,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      "Itunuoluwa Abidoye",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "itunuoluwa@petra.africa",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDrawerButton(
                    context,
                    text: 'Accueil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvantHome(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.home, color: Colors.black),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildDrawerButton(
                    context,
                    text: 'Portefeuille',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalletScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildDrawerButton(
                    context,
                    text: 'Langues',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguesEntreprise(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.language, color: Colors.black),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildDrawerButton(
                    context,
                    text: 'Notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Notifications(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications, color: Colors.black),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildDrawerButton(
                    context,
                    text: 'Confidentialité',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConditionUtilisations(),
                        ),
                      );
                      // Ajouter la logique de déconnexion ou autre
                    },
                    icon: const Icon(Icons.lock, color: Colors.black),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildDrawerButton(
                    context,
                    text: 'Profil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilUtilisateurPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person, color: Colors.black),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  _buildDrawerButton(
                    context,
                    text: 'Déconnexion',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConnexionPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF9FAFB),
        selectedItemColor: const Color(0xFFF8BF13),
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: 'Vendre'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Pièce'),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(
    BuildContext context, {
    required String text,
    required Function() onTap,
    required Icon icon,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon.icon, color: const Color(0xFFF8BF13)),
      title: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
