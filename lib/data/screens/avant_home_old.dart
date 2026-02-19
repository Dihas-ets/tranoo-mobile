import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/data/screens/wallet_screen.dart';
import 'package:tranoo/data/screens/marque.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../providers/counter_provider.dart';
import '../data/screens/marque.dart';
import '../data/screens/voitures_page.dart';
import '../data/screens/piece.dart';
import '../data/screens/profil3.dart';
import '../data/screens/cart_page.dart';
import '../data/screens/notifications.dart';
import '../data/screens/connexion_page.dart';
import '../data/screens/profile.dart';
import '../data/screens/wallet_screen.dart';
import '../data/screens/orders_page.dart';
import '../data/screens/second_page.dart';
import '../services/auth.dart' as myauth;

import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/providers/counter_provider.dart';
import 'package:tranoo/services/auth_service.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/services/cart_service.dart';
import 'package:tranoo/data/screens/profil3.dart';
import 'package:tranoo/data/screens/profile.dart';
import 'package:tranoo/data/screens/voitures.dart';
import 'package:tranoo/data/screens/orders_page.dart';
import 'package:tranoo/utils/auth_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/providers/counter_provider.dart';
import 'package:tranoo/services/auth_service.dart';
import 'package:tranoo/services/auth.dart';
import 'package:tranoo/middleware/role_middleware.dart';

import 'connexion_page.dart';
import 'package:tranoo/data/screens/second_page.dart';

class AvantHome extends StatefulWidget {
  const AvantHome({super.key});

  @override
  State<AvantHome> createState() => _AvantHomeState();
}

class _AvantHomeState extends State<AvantHome> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _didCheckOnboarding = false;
  bool _isInitialLoading = true;
  bool _hasCompletedInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingAndInactivity();
    _updateLastLoginTime();
    // Supprimé: _checkUserRole() pour permettre l'accès sans connexion
  }

  Future<void> _checkUserRole() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Attendre que l'UI soit chargée
    
    final canAccess = await RoleMiddleware.checkTranooAccess(context);
    if (!canAccess && mounted) {
      // L'utilisateur sera redirigé automatiquement par le middleware
      return;
    }
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
    // Permettre l'accès à toutes les pages sans authentification
    // Le popup d'auth sera affiché dans les pages individuelles si nécessaire
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pagesAcheteur = [
    Marque(),
    VoituresPage(),
    Piece(),
    Profil3(),
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
    // Permettre l'accès à toutes les pages même sans authentification
    // Puisqu'il n'y a plus d'autres rôles, outre que les acheteurs
    return _selectedIndex < _pagesAcheteur.length
        ? _pagesAcheteur[_selectedIndex]
        : _pagesAcheteur[0];
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

        // Gérer le chargement initial uniquement au tout premier chargement de l'app
        // Une fois que le premier chargement est terminé, ne plus cacher les éléments
        // même si loading devient true lors des changements d'authentification
        if (!_hasCompletedInitialLoad && !loading) {
            ),
          ),
        ),
        actions: [
          // Icône des commandes avec point vert si commandes en cours
          Consumer<OrderService>(
            builder: (context, orderService, child) {
              return FutureBuilder<bool>(
                future: orderService.hasPendingOrders(),
                builder: (context, snapshot) {
                  final hasPending = snapshot.data ?? false;
                  return IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.black,
                          size: iconSize,
                        ),
                        if (hasPending)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersPage(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          // Icône de panier
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
      body: getCurrentPage(role),
      drawer: Drawer(
        child: Column(
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
                    if (user == null) {
                      // Utilisateur non connecté
                      return CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person_outline,
                          size: avatarRadius * 0.9,
                          color: Colors.grey[700],
                        ),
                      );
                    }
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
                    user != null
                        ? (user['nom'] ?? "Utilisateur")
                        : "Utilisateur non connecté",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user != null) ...[
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
                    onTap: () {
                      Navigator.pop(context);
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
                    text: 'Profil',
                    onTap: () {
                      Navigator.pop(context);
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      if (firebaseUser == null) {
                        showAuthDialog(context, message: 'Connectez-vous pour accéder à votre profil');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Profile(),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.person_outline,
                      color: Colors.black,
                      size: iconSize,
                    ),
                  ),
                  _buildDrawerButton(
                    context,
                    text: 'Portefeuille',
                    onTap: () {
                      Navigator.pop(context);
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      if (firebaseUser == null) {
                        showAuthDialog(context, message: 'Connectez-vous pour accéder à votre portefeuille');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WalletScreen(),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.black,
                      size: iconSize,
                    ),
                  ),
                  if (user != null)
                    _buildDrawerButton(
                      context,
                      text: 'Déconnexion',
                      onTap: () async {
                        Navigator.pop(context);
                        await Provider.of<myauth.AuthProvider>(
                          context,
                          listen: false,
                        ).logout();
                        // Pas de redirection - rester sur la même page
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Colors.black,
                        size: iconSize,
                      ),
                    ),
                  if (user == null)
                    _buildDrawerButton(
                      context,
                      text: 'Connexion',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConnexionPage(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.login,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF9FAFB),
        selectedItemColor: const Color(0xFFF8BF13),
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (i) => _onItemTapped(i, role),
        items: [
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

// Imports manquants
import '../data/screens/orders_page.dart';
import '../data/screens/second_page.dart';

void showAuthDialog(BuildContext context, {String message = 'Veuillez vous connecter'}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Connexion requise'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
