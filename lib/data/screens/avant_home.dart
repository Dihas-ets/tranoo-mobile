import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tranoo/data/screens/wallet_screen.dart';
import 'package:tranoo/data/screens/conditionutilisations.dart';
import 'package:tranoo/data/screens/marque.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/profil3.dart';
import 'package:tranoo/data/screens/profil_utilisateur2.dart';
import 'package:tranoo/data/screens/profilutilisateurpage.dart';
import 'package:tranoo/data/screens/tarif.dart';
import 'package:tranoo/data/screens/transit.dart';
import 'package:tranoo/data/screens/une.dart';
import 'package:tranoo/data/screens/vendre.dart';
import 'package:tranoo/data/screens/voitures.dart';
import 'package:tranoo/languesentreprise.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/role_redirect.dart';

import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;

import 'connexion_page.dart';
import 'discussion.dart';
import 'chat.dart';
import 'package:tranoo/data/screens/driver_certified.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AvantHome extends StatefulWidget {
  const AvantHome({super.key});

  @override
  State<AvantHome> createState() => _AvantHomeState();
}

class _AvantHomeState extends State<AvantHome> {
  int _selectedIndex = 0;
  File? _image;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Ajout pour éviter la boucle infinie du drawer
  bool _drawerReloadCalled = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (isAcheteur) {
      // ... logique existante ...
    } else if (isChauffeur) {
      // Chauffeur
      switch (index) {
        case 0:
          // Accueil
          // ... logique existante ...
          break;
        case 1:
          // Voitures
          // ... logique existante ...
          break;
        case 2:
          // Pièces
          // ... logique existante ...
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverCertifiedPage(),
            ),
          );
          break;
      }
    } else if (isTransitaire) {
      // ... logique existante ...
      // Discussion (index 3)
      if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatListPage()),
        );
      }
    } else {
      // Vendeur
      switch (index) {
        case 0:
          // Accueil
          // ... logique existante ...
          break;
        case 1:
          // Publicité
          // ... logique existante ...
          break;
        case 2:
          // Vendre
          // ... logique existante ...
          break;
        case 3:
          // Pièces
          // ... logique existante ...
          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatListPage()),
          );
          break;
      }
    }
  }

  final userService = UserService(); // Simuler l'accès au rôle
  late bool isAcheteur;
  late bool isTransitaire;
  late bool isVendeur;
  late bool isChauffeur;

  @override
  void initState() {
    super.initState();
    final currentRole = userService.currentRole;
    isAcheteur = currentRole == UserRole.acheteur;
    isTransitaire = currentRole == UserRole.transitaire;
    isVendeur = currentRole == UserRole.vendeur;
    isChauffeur = currentRole == UserRole.chauffeur;
  }

  // Pages pour les acheteurs
  final List<Widget> _pagesAcheteur = [
    Marque(), // Accueil
    VoituresPage(), // Voitures
    Piece(), // Pièces
    Profil3(), // Profil
  ];

  // Pages pour les chauffeurs (identique acheteur sauf dernier onglet)
  final List<Widget> _pagesChauffeur = [
    Marque(), // Accueil
    VoituresPage(), // Voitures
    Piece(), // Pièces
    DriverCertifiedPage(), // Chauffeur. Certif
  ];

  // Pages normales (par exemple pour transitaires)
  final List<Widget> _pagesTransitaire = [
    Marque(),
    Tarif(),
    Transit(),
    Discussion(),
  ];
  final List<Widget> _pagesVendeur = [Marque(), Une(), Vendre(), Piece()];

  double responsiveSize(
    double screenWidth,
    double smallSize,
    double largeSize,
  ) {
    return screenWidth < 600 ? smallSize : largeSize;
  }

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

  Widget getCurrentPage() {
    if (isAcheteur) {
      return _selectedIndex < _pagesAcheteur.length
          ? _pagesAcheteur[_selectedIndex]
          : _pagesAcheteur[0];
    } else if (isChauffeur) {
      return _selectedIndex < _pagesChauffeur.length
          ? _pagesChauffeur[_selectedIndex]
          : _pagesChauffeur[0];
    } else if (isTransitaire) {
      return _selectedIndex < _pagesTransitaire.length
          ? _pagesTransitaire[_selectedIndex]
          : _pagesTransitaire[0];
    } else {
      return _selectedIndex < _pagesVendeur.length
          ? _pagesVendeur[_selectedIndex]
          : _pagesVendeur[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    // Correction RangeError : si l'utilisateur est vendeur et l'index est hors borne, on le remet sur Pièces
    if (isVendeur && _selectedIndex > 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = 3;
        });
      });
    }

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
      body: getCurrentPage(),

      drawer: Drawer(
        child: Consumer<myauth.AuthProvider>(
          builder: (context, auth, _) {
            log(
              '[Drawer] auth.user:  {auth.user}, auth.loading:  {auth.loading}',
            );
            final user = auth.user;
            if (auth.loading) {
              log('[Drawer] Affiche: Loader');
              return const Center(child: CircularProgressIndicator());
            }
            if (user == null) {
              final firebaseUser = FirebaseAuth.instance.currentUser;
              if (firebaseUser != null && !_drawerReloadCalled) {
                _drawerReloadCalled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<myauth.AuthProvider>(
                    context,
                    listen: false,
                  ).reloadUser().then((_) {
                    if (mounted)
                      setState(() {
                        _drawerReloadCalled = false;
                      });
                  });
                });
                return const Center(child: CircularProgressIndicator());
              }
              log('[Drawer] Affiche: Non connecté');
              return Center(child: Text('Non connecté ou erreur réseau'));
            }
            log('[Drawer] Affiche: Utilisateur connecté: ${user['email']}');
            // Utilisateur connecté
            return ListView(
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
                                    ? const AssetImage(
                                      "assets/images/jenifer.jpg",
                                    )
                                    : FileImage(_image!) as ImageProvider,
                          ),
                        ),
                        SizedBox(height: spacing),
                        Flexible(
                          child: Text(
                            user['nom'] ?? "Utilisateur",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            user['email'] ?? "",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: fontSize * 0.8,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                      MaterialPageRoute(
                        builder: (context) => const AvantHome(),
                      ),
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
                      MaterialPageRoute(
                        builder: (context) => const WalletScreen(),
                      ),
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
                  icon: Icon(
                    Icons.language,
                    color: Colors.black,
                    size: iconSize,
                  ),
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
                    Widget destination;
                    final role = user['role'];
                    if (role == 'acheteur') {
                      destination = const Profil3();
                    } else if (role == 'transitaire') {
                      destination = const ProfilUtilisateur2();
                    } else if (role == 'vendeur') {
                      destination = const ProfilUtilisateurPage();
                    } else {
                      destination = const Profil3();
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => destination),
                    );
                  },
                  icon: Icon(Icons.person, color: Colors.black, size: iconSize),
                ),
                _buildDrawerButton(
                  context,
                  text: 'Déconnexion',
                  onTap: () async {
                    await Provider.of<myauth.AuthProvider>(
                      context,
                      listen: false,
                    ).logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConnexionPage(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.logout, color: Colors.black, size: iconSize),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF9FAFB),
        selectedItemColor: const Color(0xFFF8BF13),
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items:
            isAcheteur
                ? [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: iconSize),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.directions_car, size: iconSize),
                    label: 'Voitures',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.build, size: iconSize),
                    label: 'Pièces',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person, size: iconSize),
                    label: 'Profil',
                  ),
                ]
                : isChauffeur
                ? [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: iconSize),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.directions_car, size: iconSize),
                    label: 'Voitures',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.build, size: iconSize),
                    label: 'Pièces',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.verified_user, size: iconSize),
                    label: 'Chauffeur. Certif',
                  ),
                ]
                : isTransitaire
                ? [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: iconSize),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money, size: iconSize),
                    label: 'Tarif',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.local_shipping, size: iconSize),
                    label: 'Transit',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.forum, size: iconSize),
                    label: 'Discussion',
                  ),
                ]
                : [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: iconSize),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.campaign, size: iconSize),
                    label: 'Publicité',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sell, size: iconSize),
                    label: 'Vendre',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.build, size: iconSize),
                    label: 'Pièces',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.forum, size: iconSize),
                    label: 'Discussion',
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
