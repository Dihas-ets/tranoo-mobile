import 'package:flutter/material.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:logging/logging.dart';

import 'connexion_page.dart'; // Assurez-vous que ce fichier existe

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  // Contrôleurs pour les champs du formulaire
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _maisonController = TextEditingController();
  final UserService _userService = UserService();
  final _logger = Logger('InscriptionPage');

  String? selectedCountry;
  String? selectedCountryCode;
  String? selectedRole;
  final List<Map<String, String>> countries = [
    {'name': 'Bénin', 'code': '+229'},
    {'name': 'Côte d\'Ivoire', 'code': '+225'},
    {'name': 'Sénégal', 'code': '+221'},
    {'name': 'Togo', 'code': '+228'},
    {'name': 'Mali', 'code': '+223'},
    {'name': 'Burkina Faso', 'code': '+226'},
    {'name': 'Niger', 'code': '+227'},
  ];

  final List<String> roles = [
    'Transitaires',
    'Acheteur',
    'Vendeur',
    'Chauffeur',
  ];
  final TextEditingController _entrepriseController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialiser le pays par défaut (Bénin)
    selectedCountry = countries[0]['name'];
    selectedCountryCode = countries[0]['code'];
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des dimensions de l'écran
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFF9FAFB), elevation: 0),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * (isPortrait ? 0.05 : 0.1),
            vertical: screenHeight * (isPortrait ? 0.02 : 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * (isPortrait ? 0.02 : 0.05)),
              Center(
                child: Image.asset(
                  "assets/images/logo_connexion.png",
                  width: screenWidth * (isPortrait ? 0.6 : 0.4),
                  height: screenHeight * (isPortrait ? 0.15 : 0.2),
                  fit: BoxFit.contain,
                ),
              ),
              // Dans votre méthode build(), remplacez le bouton d'inscription par ceci :
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom +
                        20, // Marge de sécurité
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConnexionPage(),
                        ),
                      );
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
                      minimumSize: Size(
                        0,
                        screenHeight * 0.06,
                      ), // Hauteur minimale adaptable
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              screenWidth *
                              0.04, // Taille de police fixe relative
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Trouvez votre voiture de rêve!",
                style: TextStyle(
                  fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                ),
              ),
              SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),

              // Champs du formulaire avec les contrôleurs
              buildTextFieldWithController(
                controller: _nomController,
                label: "Nom",
                icon: Icons.person,
                placeholder: "Jean",
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isPortrait: isPortrait,
              ),
              SizedBox(height: screenHeight * 0.02),
              buildTextFieldWithController(
                controller: _prenomController,
                label: "Prénom(s)",
                icon: Icons.person_outline,
                placeholder: "Dupont",
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isPortrait: isPortrait,
              ),
              SizedBox(height: screenHeight * 0.02),
              buildTextFieldWithController(
                controller: _emailController,
                label: "Adresse email",
                icon: Icons.email,
                placeholder: "jean.dupont@email.com",
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isPortrait: isPortrait,
              ),
              SizedBox(height: screenHeight * 0.02),
              // Sélection du pays (avant le champ téléphone)
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: InputDecoration(
                  labelText: 'Pays',
                  prefixIcon: const Icon(Icons.public),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    countries.map((country) {
                      return DropdownMenuItem<String>(
                        value: country['name'],
                        child: Text('${country['name']} (${country['code']})'),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                    selectedCountryCode =
                        countries.firstWhere((c) => c['name'] == value)['code'];
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              // Champ téléphone avec indicatif affiché
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      selectedCountryCode ?? '+229',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _telephoneController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Téléphone (10 chiffres)',
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              buildTextFieldWithController(
                controller: _passwordController,
                label: "Mot de passe",
                icon: Icons.lock,
                isPassword: true,
                placeholder: "********",
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isPortrait: isPortrait,
              ),
              SizedBox(height: screenHeight * 0.02),
              buildTextFieldWithController(
                controller: _confirmPasswordController,
                label: "Confirmer le mot de passe",
                icon: Icons.lock,
                isPassword: true,
                placeholder: "********",
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isPortrait: isPortrait,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Nouveau champ de sélection du rôle
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {});
                },
                child: Builder(
                  builder: (context) {
                    final focusNode = Focus.of(context);
                    final bool isFocused = focusNode.hasFocus;

                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Rôle',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color:
                              isFocused ? const Color(0xFFF8BF13) : Colors.grey,
                          size: screenWidth * (isPortrait ? 0.06 : 0.04),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.04,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                isFocused
                                    ? const Color(0xFFF8BF13)
                                    : Colors.grey,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFF8BF13),
                          ),
                        ),
                      ),
                      value: selectedRole,
                      items:
                          roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(
                                role,
                                style: TextStyle(
                                  fontSize:
                                      screenWidth * (isPortrait ? 0.04 : 0.03),
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    );
                  },
                ),
              ),
              if (selectedRole == 'Transitaires') ...[
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _entrepriseController,
                  decoration: InputDecoration(
                    labelText: 'Entreprise',
                    hintText: 'Nom de l\'entreprise',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                    prefixIcon: Icon(
                      Icons.business,
                      color: Colors.grey,
                      size: screenWidth * (isPortrait ? 0.06 : 0.04),
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
                      borderSide: const BorderSide(color: Color(0xFFF8BF13)),
                    ),
                  ),
                ),
              ],
              SizedBox(height: screenHeight * 0.02),

              SizedBox(height: screenHeight * 0.02),
              buildTextFieldWithController(
                controller: _maisonController,
                label: "Maison",
                icon: Icons.home,
                placeholder: "Rue 123, Cotonou",
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isPortrait: isPortrait,
              ),
              SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            // Vérification des champs obligatoires
                            if (_nomController.text.trim().isEmpty ||
                                _prenomController.text.trim().isEmpty ||
                                _emailController.text.trim().isEmpty ||
                                _telephoneController.text.trim().isEmpty ||
                                _passwordController.text.trim().isEmpty ||
                                _confirmPasswordController.text
                                    .trim()
                                    .isEmpty ||
                                selectedRole == null ||
                                selectedCountry == null ||
                                _maisonController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Veuillez remplir tous les champs.',
                                  ),
                                ),
                              );
                              return;
                            }
                            // Vérification email
                            final email = _emailController.text.trim();
                            final emailRegex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );
                            if (!emailRegex.hasMatch(email)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Adresse email invalide.'),
                                ),
                              );
                              return;
                            }
                            // Vérification mot de passe
                            if (_passwordController.text.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Le mot de passe doit contenir au moins 6 caractères.',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Les mots de passe ne correspondent pas.',
                                  ),
                                ),
                              );
                              return;
                            }
                            // Validation du numéro de téléphone (10 chiffres)
                            final phone = _telephoneController.text.trim();
                            final phoneRegex = RegExp(r'^\d{10}$');
                            if (!phoneRegex.hasMatch(phone)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Numéro de téléphone invalide. Entrez 10 chiffres.',
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              final fullPhone =
                                  (selectedCountryCode ?? '+229') + phone;
                              final response = await _userService.registerUser(
                                email: email,
                                password: _passwordController.text.trim(),
                                nom: _nomController.text.trim(),
                                prenoms: _prenomController.text.trim(),
                                telephone: fullPhone,
                                role: selectedRole!.toLowerCase(),
                                // fcmToken: ... (à ajouter si dispo)
                              );
                              _logger.info('Réponse inscription: $response');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Inscription réussie ! Connectez-vous.',
                                  ),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ConnexionPage(),
                                ),
                              );
                            } catch (e) {
                              String errorMsg = 'Erreur : ${e.toString()}';
                              if (e.toString().contains(
                                'email-already-in-use',
                              )) {
                                errorMsg = 'Cet email est déjà utilisé.';
                              } else if (e.toString().contains(
                                'weak-password',
                              )) {
                                errorMsg = 'Mot de passe trop faible.';
                              }
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(errorMsg)));
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
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                            "S'inscrire",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  screenWidth * (isPortrait ? 0.045 : 0.035),
                            ),
                          ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Vous avez déjà un compte ? ",
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
                          builder: (context) => const ConnexionPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Se connecter",
                      style: TextStyle(
                        color: const Color(0xFF0461B6),
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  // Nouveau builder de champ avec contrôleur
  Widget buildTextFieldWithController({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? placeholder,
    required double screenWidth,
    required double screenHeight,
    required bool isPortrait,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: Builder(
        builder: (context) {
          final focusNode = Focus.of(context);
          final bool isFocused = focusNode.hasFocus;

          return TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              labelStyle: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused ? const Color(0xFFF8BF13) : Colors.grey,
                size: screenWidth * (isPortrait ? 0.06 : 0.04),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: screenWidth * 0.04,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isFocused ? const Color(0xFFF8BF13) : Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF8BF13)),
              ),
            ),
          );
        },
      ),
    );
  }
}
