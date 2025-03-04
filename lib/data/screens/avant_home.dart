import 'package:flutter/material.dart';
import 'package:tramoo/data/screens/marque.dart';
import 'package:tramoo/data/screens/notifications.dart'; // Ajout de l'import pour la page des notifications
import 'package:tramoo/data/screens/parametres.dart';
import 'package:tramoo/data/screens/piece.dart';
import 'package:tramoo/data/screens/profilutilisateurpage.dart';
import 'package:tramoo/data/screens/recherche.dart';
import 'package:tramoo/data/screens/vendre.dart';

class AvantHome extends StatefulWidget {
  const AvantHome({super.key});

  @override
  State<AvantHome> createState() => _AvantHomeState();
}

class _AvantHomeState extends State<AvantHome> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    Vendre(),
    Recherche(),
    Marque(),
    Piece(),
    Parametres()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        toolbarHeight: 70,
        title: Center(
          child: Image.asset(
            "assets/images/logo_connexion.png",
            height: 32,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_outlined,
                    color: Colors.black, size: 32),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProfilUtilisateurPage()),
            );
          },
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF9FAFB),
        selectedItemColor: const Color(0xFFF8BF13),
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.car_crash), label: 'Vendre'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Piece'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Parametres'),
        ],
      ),
    );
  }
}
