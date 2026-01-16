import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;

import 'connexion_page.dart';
import 'marque.dart';

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
  final TextEditingController _registreCommerceController =
      TextEditingController();
  final TextEditingController _numeroIFUController = TextEditingController();
  final TextEditingController _entrepriseProvenanceController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final UserService _userService = UserService();
  final _logger = Logger('InscriptionPage');

  String? selectedCountry;
  String? selectedCountryCode;
  int selectedDigits = 8;
  String? selectedRole;
  final List<Map<String, dynamic>> countries = [
    {'name': 'Bénin', 'code': '+229', 'flag': '🇧🇯', 'digits': 8},
    {'name': 'Côte d\'Ivoire', 'code': '+225', 'flag': '🇨🇮', 'digits': 10},
    {'name': 'Sénégal', 'code': '+221', 'flag': '🇸🇳', 'digits': 9},
    {'name': 'Togo', 'code': '+228', 'flag': '🇹🇬', 'digits': 8},
    {'name': 'Mali', 'code': '+223', 'flag': '🇲🇱', 'digits': 8},
    {'name': 'Burkina Faso', 'code': '+226', 'flag': '🇧🇫', 'digits': 8},
    {'name': 'Niger', 'code': '+227', 'flag': '🇳🇪', 'digits': 8},
    {'name': 'Ghana', 'code': '+233', 'flag': '🇬🇭', 'digits': 9},
    {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬', 'digits': 10},
    {'name': 'Cameroun', 'code': '+237', 'flag': '🇨🇲', 'digits': 9},
    {'name': 'Gabon', 'code': '+241', 'flag': '🇬🇦', 'digits': 8},
    {'name': 'Congo', 'code': '+242', 'flag': '🇨🇬', 'digits': 9},
    {'name': 'RDC', 'code': '+243', 'flag': '🇨🇩', 'digits': 9},
    {'name': 'Tchad', 'code': '+235', 'flag': '🇹🇩', 'digits': 8},
    {'name': 'Centrafrique', 'code': '+236', 'flag': '🇨🇫', 'digits': 8},
    {'name': 'Guinée', 'code': '+224', 'flag': '🇬🇳', 'digits': 9},
    {'name': 'Guinée-Bissau', 'code': '+245', 'flag': '🇬🇼', 'digits': 7},
    {'name': 'Liberia', 'code': '+231', 'flag': '🇱🇷', 'digits': 8},
    {'name': 'Sierra Leone', 'code': '+232', 'flag': '🇸🇱', 'digits': 8},
    {'name': 'Mauritanie', 'code': '+222', 'flag': '🇲🇷', 'digits': 8},
    {'name': 'Gambie', 'code': '+220', 'flag': '🇬🇲', 'digits': 7},
    {'name': 'Cap-Vert', 'code': '+238', 'flag': '🇨🇻', 'digits': 7},
    {'name': 'Maroc', 'code': '+212', 'flag': '🇲🇦', 'digits': 9},
    {'name': 'Algérie', 'code': '+213', 'flag': '🇩🇿', 'digits': 9},
    {'name': 'Tunisie', 'code': '+216', 'flag': '🇹🇳', 'digits': 8},
    {'name': 'Libye', 'code': '+218', 'flag': '🇱🇾', 'digits': 9},
    {'name': 'Égypte', 'code': '+20', 'flag': '🇪🇬', 'digits': 10},
    {'name': 'Soudan', 'code': '+249', 'flag': '🇸🇩', 'digits': 9},
    {'name': 'Éthiopie', 'code': '+251', 'flag': '🇪🇹', 'digits': 9},
    {'name': 'Kenya', 'code': '+254', 'flag': '🇰🇪', 'digits': 9},
    {'name': 'Tanzanie', 'code': '+255', 'flag': '🇹🇿', 'digits': 9},
    {'name': 'Ouganda', 'code': '+256', 'flag': '🇺🇬', 'digits': 9},
    {'name': 'Rwanda', 'code': '+250', 'flag': '🇷🇼', 'digits': 9},
    {'name': 'Burundi', 'code': '+257', 'flag': '🇧🇮', 'digits': 8},
    {'name': 'Afrique du Sud', 'code': '+27', 'flag': '🇿🇦', 'digits': 9},
    {'name': 'Botswana', 'code': '+267', 'flag': '🇧🇼', 'digits': 8},
    {'name': 'Namibie', 'code': '+264', 'flag': '🇳🇦', 'digits': 8},
    {'name': 'Zambie', 'code': '+260', 'flag': '🇿🇲', 'digits': 9},
    {'name': 'Zimbabwe', 'code': '+263', 'flag': '🇿🇼', 'digits': 9},
    {'name': 'Mozambique', 'code': '+258', 'flag': '🇲🇿', 'digits': 9},
    {'name': 'Madagascar', 'code': '+261', 'flag': '🇲🇬', 'digits': 9},
    {'name': 'Maurice', 'code': '+230', 'flag': '🇲🇺', 'digits': 8},
    {'name': 'France', 'code': '+33', 'flag': '🇫🇷', 'digits': 10},
    {'name': 'Belgique', 'code': '+32', 'flag': '🇧🇪', 'digits': 9},
    {'name': 'Allemagne', 'code': '+49', 'flag': '🇩🇪', 'digits': 11},
    {'name': 'Italie', 'code': '+39', 'flag': '🇮🇹', 'digits': 10},
    {'name': 'Espagne', 'code': '+34', 'flag': '🇪🇸', 'digits': 9},
    {'name': 'Portugal', 'code': '+351', 'flag': '🇵🇹', 'digits': 9},
    {'name': 'Suisse', 'code': '+41', 'flag': '🇨🇭', 'digits': 9},
    {'name': 'Pays-Bas', 'code': '+31', 'flag': '🇳🇱', 'digits': 9},
  ];

  final List<String> roles = [
    'Acheteur',
  ];
  final TextEditingController _entrepriseController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePasswordReg = true;
  bool _obscureConfirmReg = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.transparent;

  void _updatePasswordStrength(String value) {
    double score = 0;
    if (value.isNotEmpty) {
      if (value.length >= 6) score += 0.3; // minimum
      if (value.length >= 8) score += 0.2; // recommandé
      if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.15;
      if (RegExp(r'[a-z]').hasMatch(value)) score += 0.15;
      if (RegExp(r'\\d').hasMatch(value)) score += 0.1;
      if (RegExp(r'[!@#\\$%^&*(),.?":{}|<>_\\-]').hasMatch(value)) score += 0.1;
      if (score > 1) score = 1;
    }

    String label;
    Color color;
    if (score == 0) {
      label = '';
      color = Colors.transparent;
    } else if (score < 0.4) {
      label = 'Faible';
      color = Colors.red;
    } else if (score < 0.7) {
      label = 'Moyen';
      color = Colors.orange;
    } else if (score < 0.9) {
      label = 'Fort';
      color = Colors.lightGreen;
    } else {
      label = 'Super fort';
      color = Colors.green;
    }

    setState(() {
      _passwordStrength = score;
      _passwordStrengthLabel = label;
      _passwordStrengthColor = color;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialiser le pays par défaut (Bénin)
    selectedCountry = countries[0]['name'] as String?;
    selectedCountryCode = countries[0]['code'] as String?;
    selectedDigits = countries[0]['digits'] as int;
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
                    bottom: MediaQuery.of(context).viewInsets.bottom +
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
                          fontSize: screenWidth *
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
              // Champ optionnel: Code de parrainage (statique)
              buildTextFieldWithController(
                controller: _referralController,
                label: "Code de parrainage (optionnel)",
                icon: Icons.card_giftcard,
                placeholder: "Ex: TRN-ABCD1234",
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isPortrait: isPortrait,
              ),
              SizedBox(height: screenHeight * 0.02),
              // Champ téléphone avec sélecteur de pays
              Row(
                children: [
                  // Sélecteur de pays compact
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCountry,
                        isDense: true,
                        items: countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country['name'] as String,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  country['flag'] as String,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  country['code'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          final country = countries.firstWhere(
                            (c) => c['name'] == value,
                          );
                          setState(() {
                            selectedCountry = value;
                            selectedCountryCode = country['code'] as String?;
                            selectedDigits = country['digits'] as int;
                            _telephoneController.clear(); // Vider le champ
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _telephoneController,
                      keyboardType: TextInputType.number,
                      maxLength: selectedDigits,
                      decoration: InputDecoration(
                        labelText: 'Téléphone ($selectedDigits chiffres)',
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
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD), // jaune pâle d’alerte
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFC107)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFF8A6D3B)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Utilisez un numéro joignable sur WhatsApp : il servira aux OTP et aux échanges entre notre équipe et les utilistaeurs.',
                        style: TextStyle(
                          color: Color(0xFF8A6D3B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Mot de passe avec icône oeil et jauge
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {});
                },
                child: TextField(
                  controller: _passwordController,
                  onChanged: _updatePasswordStrength,
                  obscureText: _obscurePasswordReg,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: 'Min. 6 caractères (8+ recommandé)',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: screenWidth * (isPortrait ? 0.06 : 0.04),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordReg
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePasswordReg = !_obscurePasswordReg;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
              ),
              SizedBox(height: 8),
              if (_passwordStrengthLabel.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _passwordStrengthColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Force du mot de passe: ' + _passwordStrengthLabel,
                      style: TextStyle(
                        color: _passwordStrengthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: screenHeight * 0.02),
              // Confirmation avec icône oeil
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {});
                },
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmReg,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    hintText: 'Retapez le mot de passe',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: screenWidth * (isPortrait ? 0.06 : 0.04),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmReg
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmReg = !_obscureConfirmReg;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(height: screenHeight * (isPortrait ? 0.05 : 0.1)),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Vérification des champs obligatoires
                          if (_nomController.text.trim().isEmpty ||
                              _prenomController.text.trim().isEmpty ||
                              _emailController.text.trim().isEmpty ||
                              _telephoneController.text.trim().isEmpty ||
                              _passwordController.text.trim().isEmpty ||
                              _confirmPasswordController.text.trim().isEmpty ||
                              selectedCountry == null) {
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
                          // Validation du numéro de téléphone (nombre de chiffres dynamique)
                          final phone = _telephoneController.text.trim();
                          final phoneRegex = RegExp(
                            '^\\d{$selectedDigits}\$',
                          );
                          if (!phoneRegex.hasMatch(phone)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Numéro de téléphone invalide. Entrez $selectedDigits chiffres.',
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
                            // Récupérer le code de parrainage en attente
                            final prefs = await SharedPreferences.getInstance();
                            final pendingReferral =
                                _referralController.text.trim().isNotEmpty
                                    ? _referralController.text.trim()
                                    : prefs.getString('pending_referral');

                            final response = await _userService.registerUser(
                              email: email,
                              password: _passwordController.text.trim(),
                              nom: _nomController.text.trim(),
                              prenoms: _prenomController.text.trim(),
                              telephone: fullPhone,
                              role: 'acheteur', // Toujours acheteur pour Tranoo
                              entreprise: null,
                              registreCommerce: null,
                              numeroIFU: null,
                              entrepriseProvenance: null,
                              referralCode: pendingReferral,
                              // fcmToken: ... (à ajouter si dispo)
                            );

                            if (response.data is Map) {
                              final data = response.data as Map;
                              final referralError =
                                  data['referralError']?.toString();
                              final referralInfo = data['referral'];

                              if (referralError != null &&
                                  referralError.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(referralError)),
                                );
                              } else if (referralInfo is Map &&
                                  referralInfo['status'] != null) {
                                final status =
                                    referralInfo['status']?.toString();
                                final amount =
                                    referralInfo['rewardAmount']?.toString();
                                final isAgent = referralInfo['isAgent'] == true;
                                String message =
                                    'Code de parrainage enregistré (statut: $status)';
                                if (isAgent && amount != null) {
                                  message =
                                      ' Compte crée avec succès, Parrainage agent validé ';
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }
                            }

                            // Supprimer le code de parrainage après utilisation
                            if (pendingReferral != null &&
                                _referralController.text.trim().isEmpty) {
                              await prefs.remove('pending_referral');
                            }
                            _logger.info('Réponse inscription: $response');
                            if (!mounted) return;
                            
                            // Charger l'utilisateur via AuthProvider (l'utilisateur est déjà connecté via Firebase)
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
                            
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Inscription réussie ! Bienvenue sur Tranoo.',
                                ),
                              ),
                            );
                            
                            // Mettre à jour le timestamp de dernière connexion
                            await prefs.setInt(
                              'lastLoginTime',
                              DateTime.now().millisecondsSinceEpoch,
                            );
                            
                            if (!mounted) return;
                            // Rediriger vers la page d'accueil (Marque)
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Marque(),
                              ),
                              (route) => false,
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
                  child: _isLoading
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
