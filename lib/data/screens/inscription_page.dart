import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/widgets/auth_message_popup.dart';

import 'connexion_page.dart';
import 'avant_home.dart';
import 'package:tranoo/utils/phone_country_config.dart';
import 'package:tranoo/utils/auth_config.dart';
// CAPTCHA mobile désactivé — web uniquement pour l'instant.
// import 'package:tranoo/config/turnstile_config.dart';
// import 'package:tranoo/utils/turnstile_captcha.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // Contrôleurs pour les champs du formulaire
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final UserService _userService = UserService();
  final _logger = Logger('InscriptionPage');

  String? selectedCountry;
  String? selectedCountryCode;
  int selectedDigits = 8;
  int _currentStep = 0; // 0: infos, 1: sécurité

  int _phoneMin(Map<String, dynamic> c) =>
      (c['minDigits'] ?? c['digits'] ?? 8) as int;

  int _phoneMax(Map<String, dynamic> c) =>
      (c['maxDigits'] ?? c['digits'] ?? 8) as int;

  Map<String, dynamic> get _selectedCountryMap {
    if (selectedCountry == null) return countries.first;
    for (final c in countries) {
      if (c['name'] == selectedCountry) return c;
    }
    return countries.first;
  }

  String _phoneDigitHint(AppLocalizations l10n) {
    final min = _phoneMin(_selectedCountryMap);
    final max = _phoneMax(_selectedCountryMap);
    return min == max
        ? l10n.phoneDigitsExact(max)
        : l10n.phoneDigitsRange(min, max);
  }

  bool _isValidNationalPhone(String raw) {
    final len = raw.replaceAll(RegExp(r'\D'), '').length;
    return len >= _phoneMin(_selectedCountryMap) &&
        len <= _phoneMax(_selectedCountryMap);
  }

  final List<Map<String, dynamic>> countries = [
    {'name': 'Bénin', 'code': '+229', 'flag': '🇧🇯', 'minDigits': 8, 'maxDigits': 10},
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

  bool _isLoading = false;
  bool _obscurePasswordReg = true;
  bool _obscureConfirmReg = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.transparent;

  String _localizedStrengthLabel(AppLocalizations l10n, double score) {
    if (score == 0) return '';
    if (score < 0.4) return l10n.passwordWeak;
    if (score < 0.7) return l10n.passwordMedium;
    if (score < 0.9) return l10n.passwordStrong;
    return l10n.passwordVeryStrong;
  }

  void _updatePasswordStrength(String value) {
    final l10n = AppLocalizations.of(context)!;
    double score = 0;
    if (value.isNotEmpty) {
      if (value.length >= 6) score += 0.3;
      if (value.length >= 8) score += 0.2;
      if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.15;
      if (RegExp(r'[a-z]').hasMatch(value)) score += 0.15;
      if (RegExp(r'\\d').hasMatch(value)) score += 0.1;
      if (RegExp(r'[!@#\\$%^&*(),.?":{}|<>_\\-]').hasMatch(value)) score += 0.1;
      if (score > 1) score = 1;
    }

    Color color;
    if (score == 0) {
      color = Colors.transparent;
    } else if (score < 0.4) {
      color = Colors.red;
    } else if (score < 0.7) {
      color = Colors.orange;
    } else if (score < 0.9) {
      color = Colors.lightGreen;
    } else {
      color = Colors.green;
    }

    setState(() {
      _passwordStrength = score;
      _passwordStrengthLabel = _localizedStrengthLabel(l10n, score);
      _passwordStrengthColor = color;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialiser le pays par défaut (Bénin)
    selectedCountry = countries[0]['name'] as String?;
    selectedCountryCode = countries[0]['code'] as String?;
    selectedDigits = _phoneMax(countries.first);
  }

  Widget _buildStepBar(AppLocalizations l10n) {
    const active = Color(0xFFF8BF13);
    final inactive = Colors.grey.shade300;
    return Column(
      children: [
        Row(
          children: List.generate(2, (i) {
            final isActive = i <= _currentStep;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(
                  right: i == 1 ? 0 : 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? active : inactive,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          _currentStep == 0 ? l10n.stepInfo : l10n.security,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Future<void> _openCountryPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(countries);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.72,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: l10n.searchCountryCode,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) {
                          final q = v.trim().toLowerCase();
                          setModal(() {
                            filtered = countries.where((c) {
                              final name = (c['name'] ?? '').toString().toLowerCase();
                              final code = (c['code'] ?? '').toString().toLowerCase();
                              return name.contains(q) || code.contains(q);
                            }).toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final c = filtered[index];
                          return ListTile(
                            leading: Text(
                              c['flag'] as String? ?? '',
                              style: const TextStyle(fontSize: 18),
                            ),
                            title: Text(c['name'] as String? ?? ''),
                            trailing: Text(
                              c['code'] as String? ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              setState(() {
                                selectedCountry = c['name'] as String?;
                                selectedCountryCode = c['code'] as String?;
                                selectedDigits = _phoneMax(c);
                                _telephoneController.clear();
                              });
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final bottomSafeArea = mediaQuery.padding.bottom;
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Scaffold(
      appBar: null,
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth * (isPortrait ? 0.05 : 0.1),
              screenHeight * (isPortrait ? 0.02 : 0.05),
              screenWidth * (isPortrait ? 0.05 : 0.1),
              (screenHeight * 0.03) + bottomSafeArea + bottomInset,
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
              _buildStepBar(l10n),
              SizedBox(height: screenHeight * 0.02),
              Text(
                l10n.findDreamCar,
                style: TextStyle(
                  fontSize: screenWidth * (isPortrait ? 0.04 : 0.03),
                ),
              ),
              SizedBox(height: screenHeight * (isPortrait ? 0.03 : 0.06)),

              // Champs du formulaire avec les contrôleurs
              if (_currentStep == 0) ...[
                buildTextFieldWithController(
                  controller: _nomController,
                  label: l10n.lastName,
                  icon: Icons.person,
                  placeholder: l10n.placeholderFirstName,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isPortrait: isPortrait,
                ),
                SizedBox(height: screenHeight * 0.02),
                buildTextFieldWithController(
                  controller: _prenomController,
                  label: l10n.firstName,
                  icon: Icons.person_outline,
                  placeholder: l10n.placeholderLastName,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isPortrait: isPortrait,
                ),
                SizedBox(height: screenHeight * 0.02),
                buildTextFieldWithController(
                  controller: _referralController,
                  label: l10n.referralCodeOptional,
                  icon: Icons.card_giftcard,
                  placeholder: l10n.referralPlaceholder,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isPortrait: isPortrait,
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    InkWell(
                      onTap: _openCountryPicker,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountryMap['flag']?.toString() ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selectedCountryCode ?? '+229',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
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
                          labelText: l10n.whatsappNumber,
                          hintText: l10n.whatsappHint(_phoneDigitHint(l10n)),
                          prefixIcon: AuthConfig.whatsAppPhonePrefixIcon(),
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
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFF8A6D3B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.whatsappNumberWarning,
                          style: const TextStyle(
                            color: Color(0xFF8A6D3B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nomController.text.trim().isEmpty ||
                          _prenomController.text.trim().isEmpty ||
                          _telephoneController.text.trim().isEmpty) {
                        AuthMessagePopup.showWarning(
                          context,
                          title: l10n.missingFieldsTitle,
                          subtitle: l10n.completeRequiredInfo,
                        );
                        return;
                      }
                      setState(() => _currentStep = 1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8BF13),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.nextStep,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
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
                        l10n.signInTitle,
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

              if (_currentStep == 1) ...[
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
                    labelText: l10n.password,
                    hintText: l10n.passwordMin8,
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
                      l10n.passwordStrengthLabel(_passwordStrengthLabel),
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
                    labelText: l10n.confirmPassword,
                    hintText: l10n.retypePassword,
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
                          final regL10n = AppLocalizations.of(context)!;
                          if (_nomController.text.trim().isEmpty ||
                              _prenomController.text.trim().isEmpty ||
                              _telephoneController.text.trim().isEmpty ||
                              _passwordController.text.trim().isEmpty ||
                              _confirmPasswordController.text.trim().isEmpty ||
                              selectedCountry == null) {
                            AuthMessagePopup.showWarning(
                              context,
                              title: regL10n.missingFieldsTitle,
                              subtitle: regL10n.completeRequiredInfo,
                            );
                            return;
                          }
                          if (_passwordController.text.length < 8) {
                            AuthMessagePopup.showError(
                              context,
                              title: regL10n.passwordMin8Title,
                            );
                            return;
                          }
                          if (_passwordController.text !=
                              _confirmPasswordController.text) {
                            AuthMessagePopup.showError(
                              context,
                              title: regL10n.passwordsDoNotMatch,
                            );
                            return;
                          }
                          final phone = _telephoneController.text.trim();
                          if (!_isValidNationalPhone(phone)) {
                            AuthMessagePopup.showError(
                              context,
                              title: regL10n.invalidPhoneTitle,
                              subtitle: regL10n.invalidPhoneSubtitle(
                                _phoneDigitHint(regL10n),
                                selectedCountry ?? '',
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            // --- CAPTCHA mobile (désactivé, web uniquement) ---
                            // final captchaToken =
                            //     await TurnstileCaptcha.requestToken(context);
                            // if (isTurnstileConfigured &&
                            //     (captchaToken == null ||
                            //         captchaToken.isEmpty)) {
                            //   AuthMessagePopup.showError(
                            //     context,
                            //     title: 'Contrôle de sécurité requis',
                            //     subtitle:
                            //         'Veuillez valider le contrôle de sécurité pour continuer.',
                            //   );
                            //   return;
                            // }

                            final cc = selectedCountryCode ?? '+229';
                            final email = syntheticEmailFromPhone(
                              cc,
                              phone,
                              app: TranooAuthApp.buyer,
                            );
                            final fullPhone = cc + phone;
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
                              role: 'acheteur',
                              authApp: 'tranoo',
                              entreprise: null,
                              registreCommerce: null,
                              numeroIFU: null,
                              entrepriseProvenance: null,
                              referralCode: pendingReferral,
                              // captchaToken: captchaToken,
                              // fcmToken: ... (à ajouter si dispo)
                            );

                            if (response.data is Map) {
                              final data = response.data as Map;
                              final referralError =
                                  data['referralError']?.toString();
                              final referralInfo = data['referral'];

                              if (referralError != null &&
                                  referralError.isNotEmpty) {
                                AuthMessagePopup.showWarning(
                                  context,
                                  title: referralError,
                                );
                              } else if (referralInfo is Map &&
                                  referralInfo['status'] != null) {
                                final status =
                                    referralInfo['status']?.toString();
                                final amount =
                                    referralInfo['rewardAmount']?.toString();
                                final isAgent = referralInfo['isAgent'] == true;
                                String message =
                                    regL10n.referralCodeRegistered(status ?? '');
                                if (isAgent && amount != null) {
                                  message = regL10n.accountCreatedAgentReferral;
                                }
                                AuthMessagePopup.showSuccess(
                                  context,
                                  title: message,
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
                            AuthMessagePopup.showSuccess(
                              context,
                              title: regL10n.accountCreatedTitle,
                              subtitle: regL10n.welcomeTranooExclaim,
                            );
                            
                            // Mettre à jour le timestamp de dernière connexion
                            await prefs.setInt(
                              'lastLoginTime',
                              DateTime.now().millisecondsSinceEpoch,
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
                            String title = regL10n.errorOccurredTitle;
                            String? subtitle;
                            if (e.toString().contains(
                                  'email-already-in-use',
                                )) {
                              title = regL10n.accountAlreadyExistsTitle;
                              subtitle = regL10n.accountAlreadyExistsSubtitle;
                            } else if (e.toString().contains(
                                  'weak-password',
                                )) {
                              title = regL10n.passwordMin8Title;
                            } else if (e.toString().contains('network') ||
                                e.toString().contains('SocketException') ||
                                e.toString().contains('Failed host lookup')) {
                              title = regL10n.cannotReachServer;
                              subtitle = regL10n.checkInternet;
                            } else if (e.toString().contains('server') ||
                                e.toString().contains('500') ||
                                e.toString().contains('503')) {
                              title = regL10n.serviceTemporaryIssue;
                              subtitle = regL10n.tryAgainLater;
                            }
                            AuthMessagePopup.showError(
                              context,
                              title: title,
                              subtitle: subtitle,
                              buttonText: regL10n.retry,
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
                          l10n.signUp,
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
                    l10n.alreadyHaveAccount,
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
                      l10n.signInTitle,
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
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  child: Text(l10n.back),
                ),
              ),
              ],
              ],
            ),
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
