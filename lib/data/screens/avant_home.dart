import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/data/screens/WalletScreen.dart';
import 'package:tranoo/data/screens/conditionutilisations.dart';
import 'package:tranoo/data/screens/marque.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/profilutilisateurpage.dart';
import 'package:tranoo/data/screens/une.dart';
import 'package:tranoo/data/screens/vendre.dart';
import 'package:tranoo/languesentreprise.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';
import 'package:tranoo/data/screens/profil_utilisateur2.dart';

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

  final List<Widget> _pages = [Marque(), Une(), Vendre(), Piece()];

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

  // Fonction utilitaire pour ajuster la taille en fonction de l'écran
  double responsiveSize(
    double screenWidth,
    double smallSize,
    double largeSize,
  ) {
    return screenWidth < 600 ? smallSize : largeSize;
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    // Calcul des dimensions adaptatives
    final appBarHeight = screenHeight * (isPortrait ? 0.08 : 0.12);
    final iconSize = responsiveSize(screenWidth, 24, 32);
    final logoHeight = screenHeight * (isPortrait ? 0.04 : 0.06);
    final drawerHeaderHeight = screenHeight * (isPortrait ? 0.28 : 0.35);
    final avatarRadius = screenWidth * (isPortrait ? 0.13 : 0.09);
    final spacing = screenHeight * (isPortrait ? 0.01 : 0.02);
    final fontSize = responsiveSize(screenWidth, 14, 18);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        toolbarHeight: appBarHeight,
        title: Center(
          child: Image.asset(
            "assets/images/logo_connexion.png",
            height: logoHeight,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.black,
                  size: iconSize,
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: screenWidth * 0.02,
                    height: screenWidth * 0.02,
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
          icon: Icon(Icons.menu, color: Colors.black, size: iconSize),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: drawerHeaderHeight,
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Color(0XffF8BF13)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            _image == null
                                ? const AssetImage("assets/images/jenifer.jpg")
                                : FileImage(_image!) as ImageProvider,
                      ),
                    ),
                    SizedBox(height: spacing),
                    Flexible(
                      child: Text(
                        "Itunuoluwa Abidoye",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow:
                            TextOverflow
                                .ellipsis, // Ajout pour éviter le débordement
                        maxLines: 1, // Limite à une seule ligne
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "itunuoluwa@petra.africa",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: fontSize * 0.8,
                        ),
                        overflow:
                            TextOverflow
                                .ellipsis, // Ajout pour éviter le débordement
                        maxLines: 1, // Limite à une seule ligne
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerButton(
              context,
              text: 'Accueil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AvantHome()),
                );
              },
              icon: Icon(Icons.home, color: Colors.black, size: iconSize),
            ),
            _buildDrawerButton(
              context,
              text: 'Portefeuille',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletScreen()),
                );
              },
              icon: Icon(
                Icons.account_balance_wallet,
                color: Colors.black,
                size: iconSize,
              ),
            ),
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
              icon: Icon(Icons.language, color: Colors.black, size: iconSize),
            ),
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
              icon: Icon(
                Icons.notifications,
                color: Colors.black,
                size: iconSize,
              ),
            ),
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
              },
              icon: Icon(Icons.lock, color: Colors.black, size: iconSize),
            ),
            _buildDrawerButton(
              context,
              text: 'Profil',
              onTap: () {
                final userService = UserService();
                if (userService.currentRole == UserRole.transitaire) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilUtilisateur2(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilUtilisateurPage(),
                    ),
                  );
                }
              },
              icon: Icon(Icons.person, color: Colors.black, size: iconSize),
            ),
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
              icon: Icon(Icons.logout, color: Colors.black, size: iconSize),
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: iconSize),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: iconSize),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash, size: iconSize),
            label: 'Vendre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build, size: iconSize),
            label: 'Pièce',
          ),
                 BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Publicité',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_crash), 
            label: 'Vendre'),
          BottomNavigationBarItem(
            icon: Icon(Icons.build), 
            label: 'Pièce'
            ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = responsiveSize(screenWidth, 14, 18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon.icon, color: const Color(0xFFF8BF13), size: icon.size),
              const SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(color: Colors.black, fontSize: fontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
