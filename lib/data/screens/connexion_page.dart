import 'package:flutter/material.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/widgets/auth_message_popup.dart';

import 'inscription_page.dart';
import 'avant_home.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  bool isEmailFocused = false;
  bool isPasswordFocused = false;
  final userService = UserService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final _logger = Logger('ConnexionPage');
  bool _obscurePasswordLogin = true;

  Future<String?> fetchUserRole() async {
    // Récupère le token Firebase de l'utilisateur connecté
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final idToken = await user.getIdToken();
    // Appel backend pour récupérer le profil utilisateur (exemple)
    final response = await userService.dio.get(
      '/protected/me',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    return response.data['user']['role'];
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * (isPortrait ? 0.05 : 0.1),
            vertical: screenHeight * (isPortrait ? 0.02 : 0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * (isPortrait ? 0.1 : 0.05)),
              Center(
                child: Image.asset(
                  "assets/images/logo_connexion.png",
                  width: screenWidth * (isPortrait ? 0.6 : 0.4),
                  height: screenHeight * (isPortrait ? 0.15 : 0.2),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),
              Text(
                "Se connecter",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * (isPortrait ? 0.06 : 0.04),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Bienvenue sur Tranoo",
                style: TextStyle(
                  fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                ),
              ),
              SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),

              // Champ Email
              Focus(
                onFocusChange: (focused) {
                  setState(() => isEmailFocused = focused);
                },
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: isEmailFocused ? Colors.amber : Colors.grey,
                      size: screenWidth * (isPortrait ? 0.06 : 0.04),
                    ),
                    hintText: "exemple@mail.com",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Champ Mot de passe
              Focus(
                onFocusChange: (focused) {
                  setState(() => isPasswordFocused = focused);
                },
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePasswordLogin,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: isPasswordFocused ? Colors.amber : Colors.grey,
                      size: screenWidth * (isPortrait ? 0.06 : 0.04),
                    ),
                    hintText: "••••••••",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordLogin
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePasswordLogin = !_obscurePasswordLogin;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.amber,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Lien "Mot de passe oublié"
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/auth/forgot-password');
                },
                child: Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(
                    fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Bouton Se connecter
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Vérification des champs obligatoires
                          if (_emailController.text.trim().isEmpty ||
                              _passwordController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Veuillez remplir tous les champs.',
                                ),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });
                          _logger.info(
                            'Tentative de connexion avec email: ${_emailController.text.trim()}',
                          );
                          try {
                            await userService.loginUser(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                            _logger.info(
                              'Connexion Firebase réussie pour: ${_emailController.text.trim()}',
                            );

                            // Charger l'utilisateur et le rôle via AuthProvider puis naviguer
                            final auth = context.read<myauth.AuthProvider>();
                            await auth.reloadUser();

                            // Attendre brièvement que l'état soit bien propagé
                            final startWait = DateTime.now();
                            while (auth.user == null &&
                                DateTime.now().difference(startWait) <
                                    const Duration(seconds: 5)) {
                              await Future.delayed(
                                const Duration(milliseconds: 100),
                              );
                            }

                            if (auth.user == null) {
                              throw Exception(
                                "La session n'a pas pu être initialisée. Réessayez.",
                              );
                            }
                            final userRole =
                                auth.user?['role']?.toString().toLowerCase();
                            if (userRole != 'acheteur') {
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              AuthMessagePopup.showError(
                                context,
                                title:
                                    'Compte non autorisé sur Tranoo Acheteur.',
                                subtitle:
                                    'Connectez-vous sur Tranoo Pro avec ce compte.',
                                buttonText: 'Compris',
                              );
                              return;
                            }

                            // Mettre à jour le timestamp de dernière connexion
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt(
                              'lastLoginTime',
                              DateTime.now().millisecondsSinceEpoch,
                            );

                            if (!mounted) return;
                            AuthMessagePopup.showSuccess(
                              context,
                              title: 'Connexion réussie. Bienvenue !',
                            );

                            if (!mounted) return;
                            // Rediriger vers la page d'accueil avec drawer et navbar
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AvantHome(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            _logger.warning(
                              'Erreur lors de la connexion Firebase: ${e.toString()}',
                            );
                            String title =
                                'Impossible de se connecter avec ces informations.';
                            String? subtitle;
                            if (e.toString().contains('user-not-found')) {
                              title =
                                  'Aucun compte n\'est associé à cet email.';
                              subtitle = 'Créez un compte pour continuer.';
                            } else if (e.toString().contains(
                                  'wrong-password',
                                )) {
                              title = 'Mot de passe incorrect.';
                              subtitle =
                                  'Vérifiez vos informations et réessayez.';
                            } else if (e.toString().contains(
                                  'invalid-credential',
                                )) {
                              title = 'Email ou mot de passe incorrect.';
                              subtitle =
                                  'Vérifiez vos informations et réessayez.';
                            } else if (e.toString().contains('user-disabled')) {
                              title = 'Votre compte est temporairement bloqué.';
                              subtitle = 'Contactez l\'assistance.';
                            } else if (e
                                .toString()
                                .contains('too-many-requests')) {
                              title = 'Trop de tentatives de connexion.';
                              subtitle = 'Réessayez dans quelques minutes.';
                            } else if (e.toString().contains('network') ||
                                e.toString().contains('SocketException') ||
                                e.toString().contains('Failed host lookup')) {
                              title = 'Impossible de se connecter au serveur.';
                              subtitle = 'Vérifiez votre connexion internet.';
                            } else if (e.toString().contains('server') ||
                                e.toString().contains('500') ||
                                e.toString().contains('503')) {
                              title =
                                  'Notre service rencontre un problème temporaire.';
                              subtitle = 'Veuillez réessayer plus tard.';
                            }
                            if (!mounted) return;
                            AuthMessagePopup.showError(
                              context,
                              title: title,
                              subtitle: subtitle,
                              buttonText: 'Réessayer',
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8BF13),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          'Se connecter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                screenWidth * (isPortrait ? 0.045 : 0.035),
                          ),
                        ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Lien vers l'inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous n'avez pas de compte ? ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InscriptionPage(),
                        ),
                      );
                    },
                    child: Text(
                      "S'inscrire",
                      style: TextStyle(
                        color: const Color(0xFF0461B6),
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cette méthode n'est plus utilisée - seuls les acheteurs sont autorisés
  // UserRole _getUserRoleFromString(String? role) {
  //   switch (role) {
  //     case 'acheteur':
  //       return UserRole.acheteur;
  //     default:
  //       return UserRole.acheteur;
  //   }
  // }
}
