import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/cart_service.dart';
import '../../providers/counter_provider.dart';
import 'marque.dart';
import 'voitures.dart';
import 'piece.dart';
import 'profil3.dart';
import 'profilutilisateurpage.dart';
import 'profil_utilisateur2.dart';
import 'cart_page.dart';
import 'notifications.dart';
import 'connexion_page.dart';
import 'mesfactures.dart';
import 'second_page.dart';
import '../../providers/auth_provider.dart' as myauth;

class AvantHome extends StatefulWidget {
  const AvantHome({super.key});

  @override
  State<AvantHome> createState() => _AvantHomeState();
}

class _AvantHomeState extends State<AvantHome> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _didCheckOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingAndInactivity();
    _updateLastLoginTime();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const Marque(),
    const VoituresPage(),
    const Piece(),
    const Profil3(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myauth.AuthProvider>(context).user;
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: SizedBox(
          height: 40,
          child: Center(
            child: Image.asset(
              'assets/images/logo_connexion.png',
              height: 32,
              fit: BoxFit.contain,
              // Aucun texte de fallback pour éviter d'afficher "Tranoo"
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MesFacturesPage()),
              );
            },
          ),
          Consumer<CartService>(
            builder: (context, cart, child) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.black),
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
                            cart.totalQuantity.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
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
                    const Icon(Icons.notifications_none_outlined, color: Colors.black),
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
                            counter.unreadNotificationsCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0XffF8BF13),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: user != null
                        ? const Icon(Icons.person, size: 40)
                        : const Icon(Icons.person_outline, size: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user != null ? (user['nom'] ?? "Utilisateur") : "Utilisateur non connecté",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user != null) ...[
                    Text(
                      user['email'] ?? "",
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Accueil'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AvantHome()),
                      );
                    },
                  ),
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Compte',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profil'),
                    onTap: () {
                      Navigator.pop(context);
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez vous connecter')),
                        );
                        return;
                      }
                      final role = user['role'] as String?;
                      final Widget page = role == 'vendeur'
                          ? const ProfilUtilisateurPage()
                          : role == 'transitaire'
                              ? const ProfilUtilisateur2()
                              : const Profil3();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => page),
                      );
                    },
                  ),
                  if (user != null)
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Déconnexion'),
                      onTap: () async {
                        Navigator.pop(context);
                        await Provider.of<myauth.AuthProvider>(context, listen: false).logout();
                      },
                    ),
                  if (user == null)
                    ListTile(
                      leading: const Icon(Icons.login),
                      title: const Text('Connexion'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConnexionPage()),
                        );
                      },
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
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Voitures'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Pièces'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
