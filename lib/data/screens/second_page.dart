import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/data/screens/connexion_page.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  SecondPageState createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  int _currentImageIndex = 0;
  final List<String> _images = [
    'assets/images/voiture_deuxieme_page.png',
    'assets/images/image_background.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _startImageSlideshow();
  }

  void _startImageSlideshow() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextImage();
    });
  }

  void _nextImage() {
    if (!mounted) return;
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _images.length;
    });
    
    // Continuer le défilement
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _nextImage();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📸 Images d'arrière-plan qui défilent
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: Container(
              key: ValueKey(_currentImageIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_images[_currentImageIndex]),
                  fit: _images[_currentImageIndex].contains('voiture_deuxieme_page') 
                      ? BoxFit.contain 
                      : BoxFit.cover,
                  scale: _images[_currentImageIndex].contains('voiture_deuxieme_page') 
                      ? 1.2 
                      : 1.0,
                ),
              ),
            ),
          ),

          // 🌫️ Dégradé sombre pour rendre le texte lisible
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withAlpha(60), Colors.transparent],
              ),
            ),
          ),

          // 📄 Texte et bouton
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 30.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Découvrez votre\nvéhicule idéal en\nquelques clics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 🔘 Bouton fléché
                Row(
                  children: [
                    Expanded(child: SizedBox()),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffF8BF13).withAlpha(50),
                            spreadRadius: 0,
                            blurRadius: 50,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          // Marquer l'onboarding comme vu
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasSeenOnboarding', true);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConnexionPage(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.arrow_circle_right,
                          color: Color(0xffF8BF13),
                          size: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


