import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/data/screens/wallet_screen.dart';
import 'package:tranoo/data/screens/marque.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/cart_page.dart';
import 'package:tranoo/services/cart_service.dart';
import 'package:tranoo/data/screens/profil3.dart';
import 'package:tranoo/data/screens/profile.dart';
import 'package:tranoo/data/screens/tarif.dart';
import 'package:tranoo/data/screens/transit.dart';
// import 'package:tranoo/data/screens/une.dart'; // Masqué temporairement (onglet Publicité)
import 'package:tranoo/data/screens/vendre.dart';
import 'package:tranoo/data/screens/voitures.dart';

import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/providers/counter_provider.dart';

import 'connexion_page.dart';
import 'chat.dart';
import 'package:tranoo/data/screens/driver_certified.dart';
import 'package:tranoo/data/screens/second_page.dart';
import 'package:tranoo/data/screens/une.dart';

class AvantHome extends StatefulWidget {
  const AvantHome({super.key});

  @override
  State<AvantHome> createState() => _AvantHomeState();
}

class _AvantHomeState extends State<AvantHome> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _didRedirectToLogin = false;
  bool _didCheckOnboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final counterProvider = Provider.of<CounterProvider>(
          context,
          listen: false,
        );
        counterProvider.loadCounters();
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

    if (!hasSeenOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SecondPage()),
          (route) => false,
        );
      });
      return;
    }
  }

  Future<void> _updateLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastLoginTime', DateTime.now().millisecondsSinceEpoch);
  }

  void _onItemTapped(int index, String? role) {
    setState(() {
      _selectedIndex = index;
    });
    // Chat est maintenant intégré dans les onglets, pas besoin de Navigator.push
    if (role == 'chauffeur' && index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DriverCertifiedPage()),
      );
    }
    // Les transitaires et vendeurs accèdent à Chat via les onglets directement
  }

  final List<Widget> _pagesAcheteur = [
    Marque(),
    VoituresPage(),
    Piece(),
    Profil3(),
  ];

  final List<Widget> _pagesChauffeur = [
    Marque(),
    VoituresPage(),
    Piece(),
    DriverCertifiedPage(),
  ];

  final List<Widget> _pagesTransitaire = [
    Marque(),
    Tarif(),
    Transit(),
    ChatListPage(),
  ];

  final List<Widget> _pagesVendeur = [
    Marque(),
    const Une(isStandalone: true),
    Vendre(),
    Piece(),
    ChatListPage(),
  ];

  double responsiveSize(
    double screenWidth,
    double smallSize,
    double largeSize,
  ) {
    return screenWidth < 600 ? smallSize : largeSize;
  }

  void _showAvatarDialog(String? photoUrl) {
    showDialog(
      context: context,
      builder: (ctx) {
        final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
        return Dialog(
          backgroundColor: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      hasPhoto ? NetworkImage(photoUrl) : null,
                  child: hasPhoto
                      ? null
                      : const Icon(
                          Icons.person_outline,
                          size: 80,
                          color: Colors.white70,
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

    return Consumer<myauth.AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final loading = auth.loading;
        final role = user != null ? user['role'] as String? : null;

        if (!loading && !_didCheckOnboarding) {
          _checkOnboardingAndInactivity();
        }

        if (!loading &&
            user == null &&
            !_didRedirectToLogin &&
            _didCheckOnboarding) {
          _didRedirectToLogin = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ConnexionPage()),
              (route) => false,
            );
          });
        }

        if (user != null) {
          _updateLastLoginTime();
        }

        // Ajusté pour 5 onglets (Accueil, Vendre, Pièces, Chat, Profil)
        if (role == 'vendeur' && _selectedIndex > 4) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedIndex = 4;
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
                height: logoHeight + 6,
              ),
            ),
            actions: [
              // Icône de panier (seulement pour les non-vendeurs)
              if (role != 'vendeur')
                Consumer<CartService>(
                  builder: (context, cart, child) {
                    return IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.black,
                            size: iconSize,
                          ),
                          if (cart.totalQuantity > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  cart.totalQuantity > 99
                                      ? '99+'
                                      : cart.totalQuantity.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
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
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              Consumer<CounterProvider>(
                builder: (context, counter, child) {
                  return IconButton(
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
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : getCurrentPage(role),
          drawer: Drawer(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : user == null
                    ? const Center(child: Text('Non connecté'))
                    : Column(
                        children: [
                          // Header fixe
                          Container(
                            width: double.infinity,
                            height: drawerHeaderHeight + 20,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            decoration: const BoxDecoration(
                              color: Color(0XffF8BF13),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Builder(builder: (context) {
                                  final photoUrl = (user['photo'] as String?) ?? '';
                                  final hasPhoto = photoUrl.isNotEmpty;
                                  return GestureDetector(
                                    onTap: () => _showAvatarDialog(photoUrl),
                                  child: CircleAvatar(
                                    radius: avatarRadius,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: hasPhoto
                                          ? NetworkImage(photoUrl)
                                          : null,
                                      child: !hasPhoto
                                          ? Icon(
                                              Icons.person_outline,
                                              size: avatarRadius * 0.9,
                                              color: Colors.grey[700],
                                          )
                                          : null,
                                  ),
                                  );
                                }),
                                SizedBox(height: spacing),
                                Text(
                                  user['nom'] ?? "Utilisateur",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user['email'] ?? "",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fontSize * 0.8,
                                  ),
                                ),
                                if (user['role'] != null)
                                  Text(
                                    (user['role'] as String).toUpperCase(),
                                    style: TextStyle(
                                      color: const Color(0xFF0A1F44),
                                      fontSize: fontSize * 0.75,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Liste scrollable
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                _buildDrawerButton(
                                  context,
                                  text: 'Accueil',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AvantHome(),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.home,
                                    color: Colors.black,
                                    size: iconSize,
                                  ),
                                ),
                                _buildDrawerButton(
                                  context,
                                  text: 'Profil',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Profile(),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.person_outline,
                                    color: Colors.black,
                                    size: iconSize,
                                  ),
                                ),
                                _buildDrawerButton(
                                  context,
                                  text: 'Portefeuille',
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WalletScreen(),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.account_balance_wallet,
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
                                        builder: (context) =>
                                            const ConnexionPage(),
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
                        ],
                      ),
          ),
          bottomNavigationBar: loading
              ? null
              : BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: const Color(0xFFF9FAFB),
                  selectedItemColor: const Color(0xFFF8BF13),
                  unselectedItemColor: Colors.black,
                  currentIndex: _selectedIndex,
                  onTap: (i) => _onItemTapped(i, role),
                  items: role == 'acheteur'
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
                                icon: Icon(Icons.chat, size: iconSize),
                                label: 'Chat',
                              ),
                            ]
                          : role == 'transitaire'
                              ? [
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.home, size: iconSize),
                                    label: 'Accueil',
                                  ),
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.workspace_premium,
                                        size: iconSize),
                                    label: 'Abonnement',
                                  ),
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.local_shipping,
                                        size: iconSize),
                                    label: 'Transits',
                                  ),
                                  BottomNavigationBarItem(
                                    icon: Icon(Icons.chat, size: iconSize),
                                    label: 'Chat',
                                  ),
                                ]
                              : [
                                  // Chauffeurs et autres rôles
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
