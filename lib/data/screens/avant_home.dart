import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/providers/counter_provider.dart';

import 'connexion_page.dart';
import 'chat.dart';
import 'package:tranoo/data/screens/driver_certified.dart';
import 'package:tranoo/data/screens/first_page.dart';

class AvantHome extends StatefulWidget {
  const AvantHome({super.key});

  @override
  State<AvantHome> createState() => _AvantHomeState();
}

class _AvantHomeState extends State<AvantHome> {
  int _selectedIndex = 0;
  File? _image;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _didRedirectToLogin = false;
  bool _didCheckOnboarding = false;

  @override
  void initState() {
    super.initState();
    // La vérification de l'onboarding se fera dans le builder

    // Charger les compteurs après un délai pour laisser l'interface se charger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final counterProvider = Provider.of<CounterProvider>(
          context,
          listen: false,
        );
        print('DEBUG: Chargement des compteurs...');
        counterProvider
            .loadCounters()
            .then((_) {
              print(
                'DEBUG: Compteurs chargés - Messages: ${counterProvider.unreadMessagesCount}, Notifications: ${counterProvider.unreadNotificationsCount}',
              );
            })
            .catchError((error) {
              print('DEBUG: Erreur chargement compteurs: $error');
            });
      } catch (e) {
        print('DEBUG: Erreur accès CounterProvider: $e');
      }
    });
  }

  Future<void> _checkOnboardingAndInactivity() async {
    if (_didCheckOnboarding) return;
    _didCheckOnboarding = true;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    print('DEBUG: hasSeenOnboarding = $hasSeenOnboarding');

    // Si première installation → rediriger vers onboarding
    if (!hasSeenOnboarding) {
      print(
        'DEBUG: Première installation détectée, redirection vers FirstPage',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FirstPage()),
          (route) => false,
        );
      });
      return;
    }

    // Si l'onboarding a été vu, on ne fait rien ici
    // La vérification de l'utilisateur se fera dans le builder
  }

  Future<void> _updateLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastLoginTime', DateTime.now().millisecondsSinceEpoch);
  }

  void _onItemTapped(int index, String? role) {
    setState(() {
      _selectedIndex = index;
    });
    if (role == 'acheteur') {
      // ... logique existante ...
    } else if (role == 'chauffeur') {
      switch (index) {
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverCertifiedPage(),
            ),
          );
          break;
      }
    } else if (role == 'transitaire') {
      if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatListPage()),
        );
      }
    } else if (role == 'vendeur') {
      switch (index) {
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatListPage()),
          );
          break;
      }
    }
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
    ChatListPage(),
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

  Widget getCurrentPage(String? role) {
    if (role == 'acheteur') {
      return _selectedIndex < _pagesAcheteur.length
          ? _pagesAcheteur[_selectedIndex]
          : _pagesAcheteur[0];
    } else if (role == 'chauffeur') {
      return _selectedIndex < _pagesChauffeur.length
          ? _pagesChauffeur[_selectedIndex]
          : _pagesChauffeur[0];
    } else if (role == 'transitaire') {
      return _selectedIndex < _pagesTransitaire.length
          ? _pagesTransitaire[_selectedIndex]
          : _pagesTransitaire[0];
    } else if (role == 'vendeur') {
      return _selectedIndex < _pagesVendeur.length
          ? _pagesVendeur[_selectedIndex]
          : _pagesVendeur[0];
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final appBarHeight = screenHeight * (isPortrait ? 0.08 : 0.12);
    final iconSize = responsiveSize(screenWidth, 24, 32);
    final logoHeight = screenHeight * (isPortrait ? 0.04 : 0.06);
    final drawerHeaderHeight = screenHeight * (isPortrait ? 0.28 : 0.35);
    final avatarRadius = screenWidth * (isPortrait ? 0.13 : 0.09);
    final spacing = screenHeight * (isPortrait ? 0.01 : 0.02);
    final fontSize = responsiveSize(screenWidth, 14, 18);

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CounterProvider())],
      child: Consumer<myauth.AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          final loading = auth.loading;
          final role = user != null ? user['role'] as String? : null;

          // Vérifier d'abord si c'est la première installation
          if (!loading && !_didCheckOnboarding) {
            _checkOnboardingAndInactivity();
          }

          // Si pas connecté et pas en chargement ET que l'onboarding a été vu: rediriger vers la page de connexion
          if (!loading &&
              user == null &&
              !_didRedirectToLogin &&
              _didCheckOnboarding) {
            _didRedirectToLogin = true;
            print(
              'DEBUG: Utilisateur non connecté, redirection vers ConnexionPage',
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ConnexionPage()),
                (route) => false,
              );
            });
          }

          // Si utilisateur connecté, mettre à jour le timestamp de dernière connexion
          if (user != null) {
            _updateLastLoginTime();
          }

          // Correction RangeError : si l'utilisateur est vendeur et l'index est hors borne, on le remet sur Pièces
          if (role == 'vendeur' && _selectedIndex > 3) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedIndex = 3;
              });
            });
          }

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
                Consumer<CounterProvider>(
                  builder: (context, counter, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton de test pour recharger les compteurs
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          onPressed: () {
                            print(
                              'DEBUG: Rechargement manuel des compteurs...',
                            );
                            counter.loadCounters().then((_) {
                              print(
                                'DEBUG: Compteurs rechargés - Messages: ${counter.unreadMessagesCount}, Notifications: ${counter.unreadNotificationsCount}',
                              );
                            });
                          },
                        ),
                        // Badge notifications
                        IconButton(
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_none_outlined,
                                color: Colors.black,
                                size: iconSize,
                              ),
                              if (counter.unreadNotificationsCount > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      counter.unreadNotificationsCount > 99
                                          ? '99+'
                                          : counter.unreadNotificationsCount
                                              .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Notifications(),
                              ),
                            );
                          },
                        ),
                      ],
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
            body:
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : getCurrentPage(role),
            drawer: Drawer(
              child:
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : user == null
                      ? Center(child: Text('Non connecté ou erreur réseau'))
                      : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          SizedBox(
                            height: drawerHeaderHeight,
                            child: DrawerHeader(
                              decoration: const BoxDecoration(
                                color: Color(0XffF8BF13),
                              ),
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
                                              : FileImage(_image!)
                                                  as ImageProvider,
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
                            icon: Icon(
                              Icons.home,
                              color: Colors.black,
                              size: iconSize,
                            ),
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
                                  builder:
                                      (context) => const LanguesEntreprise(),
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
                                  builder:
                                      (context) =>
                                          const ConditionUtilisations(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.lock,
                              color: Colors.black,
                              size: iconSize,
                            ),
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
                                MaterialPageRoute(
                                  builder: (context) => destination,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.person,
                              color: Colors.black,
                              size: iconSize,
                            ),
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
                            icon: Icon(
                              Icons.logout,
                              color: Colors.black,
                              size: iconSize,
                            ),
                          ),
                        ],
                      ),
            ),
            bottomNavigationBar:
                loading
                    ? null
                    : BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: const Color(0xFFF9FAFB),
                      selectedItemColor: const Color(0xFFF8BF13),
                      unselectedItemColor: Colors.black,
                      currentIndex: _selectedIndex,
                      onTap: (i) => _onItemTapped(i, role),
                      items:
                          role == 'acheteur'
                              ? [
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.home, size: iconSize),
                                  label: 'Accueil',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.directions_car,
                                    size: iconSize,
                                  ),
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
                              : role == 'chauffeur'
                              ? [
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.home, size: iconSize),
                                  label: 'Accueil',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.directions_car,
                                    size: iconSize,
                                  ),
                                  label: 'Voitures',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.build, size: iconSize),
                                  label: 'Pièces',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.verified_user,
                                    size: iconSize,
                                  ),
                                  label: 'Chauffeur. Certif',
                                ),
                              ]
                              : role == 'transitaire'
                              ? [
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.home, size: iconSize),
                                  label: 'Accueil',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.attach_money,
                                    size: iconSize,
                                  ),
                                  label: 'Tarif',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.local_shipping,
                                    size: iconSize,
                                  ),
                                  label: 'Transit',
                                ),
                                BottomNavigationBarItem(
                                  icon: Consumer<CounterProvider>(
                                    builder: (context, counter, child) {
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Icon(Icons.forum, size: iconSize),
                                          if (counter.unreadMessagesCount > 0)
                                            Positioned(
                                              right: -2,
                                              top: -2,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 16,
                                                      minHeight: 16,
                                                    ),
                                                child: Text(
                                                  counter.unreadMessagesCount >
                                                          99
                                                      ? '99+'
                                                      : counter
                                                          .unreadMessagesCount
                                                          .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  label: 'Discussion',
                                ),
                              ]
                              : role == 'vendeur'
                              ? [
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
                                  icon: Consumer<CounterProvider>(
                                    builder: (context, counter, child) {
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Icon(Icons.forum, size: iconSize),
                                          if (counter.unreadMessagesCount > 0)
                                            Positioned(
                                              right: -2,
                                              top: -2,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 16,
                                                      minHeight: 16,
                                                    ),
                                                child: Text(
                                                  counter.unreadMessagesCount >
                                                          99
                                                      ? '99+'
                                                      : counter
                                                          .unreadMessagesCount
                                                          .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  label: 'Discussion',
                                ),
                              ]
                              : [
                                // Cas par défaut: afficher les items acheteur
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.home, size: iconSize),
                                  label: 'Accueil',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.directions_car,
                                    size: iconSize,
                                  ),
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
                              ],
                    ),
          );
        },
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
