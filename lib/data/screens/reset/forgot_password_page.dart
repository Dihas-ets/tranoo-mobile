import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'package:tranoo/utils/auth_config.dart';
import 'package:tranoo/utils/phone_country_config.dart';
import 'package:tranoo/widgets/auth_message_popup.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  String? selectedCountry;
  String? selectedCountryCode;
  bool _loading = false;

  PhoneCountryConfig get _phoneCountry =>
      phoneCountryByName(selectedCountry);

  int get _maxNationalDigits => _phoneCountry.maxDigits;

  @override
  void initState() {
    super.initState();
    selectedCountry = kPhoneCountries.first.name;
    selectedCountryCode = kPhoneCountries.first.code;
    PushOTPService.setupNotificationHandlers();
    // Prépare le token FCM même sans connexion préalable (mot de passe oublié)
    PushOTPService.getFCMToken();
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    super.dispose();
  }

  void _onNationalChanged(String value) {
    final cc = phoneDigitsOnly(selectedCountryCode ?? '+229');
    if (cc != '229') return;
    final digits = phoneDigitsOnly(value);
    String? normalized;
    if (digits.startsWith('01') && digits.length >= 10) {
      normalized = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length > 1) {
      normalized = digits.replaceFirst(RegExp(r'^0+'), '');
    }
    if (normalized != null && normalized != digits) {
      _identifierCtrl.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
  }

  Future<void> _openCountryPicker() async {
    final search = TextEditingController();
    var filtered = List<PhoneCountryConfig>.from(kPhoneCountries);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: search,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un pays',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) {
                    final q = v.trim().toLowerCase();
                    setModal(() {
                      filtered = kPhoneCountries
                          .where((c) =>
                              c.name.toLowerCase().contains(q) ||
                              c.code.contains(q))
                          .toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    return ListTile(
                      leading: Text(c.flag),
                      title: Text(c.name),
                      trailing: Text(c.code),
                      onTap: () {
                        setState(() {
                          selectedCountry = c.name;
                          selectedCountryCode = c.code;
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
      ),
    );
  }

  String _passwordResetErrorTitle(String? raw) {
    final msg = (raw ?? '').trim();
    final lower = msg.toLowerCase();
    if (lower.contains('aucun compte') ||
        lower.contains('trouvé pour') ||
        lower.contains('pas trouvé') ||
        lower.contains('introuvable') ||
        lower.contains('n\'existe pas')) {
      return 'Aucun compte trouvé pour ce numéro.';
    }
    if (msg.isEmpty) return 'Une erreur est survenue.';
    return msg;
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final raw = _identifierCtrl.text.trim();
      final cc = selectedCountryCode ?? '+229';
      final telephone = buildInternationalPhone(cc, raw);

      debugPrint('[RESET] Envoi code → $telephone (national: $raw, pays: $cc)');
      final result = await PushOTPService.requestPasswordReset(
        telephone: telephone,
        countryCode: cc,
        nationalNumber: raw,
        app: 'tranoo',
      );
      debugPrint('[RESET] Réponse: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        final requestId = result['requestId']?.toString();
        final sessionDeviceId = result['deviceId']?.toString();
        if (requestId == null ||
            requestId.isEmpty ||
            sessionDeviceId == null ||
            sessionDeviceId.isEmpty) {
          AuthMessagePopup.showError(
            context,
            title: 'Réponse serveur incomplète.',
            subtitle: 'Réessayez dans quelques instants.',
            buttonText: 'Réessayer',
          );
          return;
        }
        final msg = result['message'] as String? ??
            'Code envoyé sur WhatsApp au numéro de votre compte.';
        await AuthMessagePopup.showInfo(
          context,
          title: 'Code envoyé',
          subtitle: msg,
        );
        if (!mounted) return;
        final devOtp = result['devOtp']?.toString();
        Navigator.pushNamed(
          context,
          '/auth/verify-reset',
          arguments: {
            'requestId': requestId,
            'deviceId': sessionDeviceId,
            'expiresInSeconds': result['expiresInSeconds'] ?? 600,
            if (devOtp != null && devOtp.isNotEmpty) 'initialOtp': devOtp,
          },
        );
      } else {
        final msg = result['message'] as String?;
        AuthMessagePopup.showError(
          context,
          title: _passwordResetErrorTitle(msg),
          subtitle: _passwordResetErrorTitle(msg) ==
                  'Aucun compte trouvé pour ce numéro.'
              ? 'Utilisez le même numéro WhatsApp qu\'à l\'inscription (sans 0 après +229).'
              : null,
          buttonText: 'Réessayer',
        );
      }
    } catch (e) {
      if (!mounted) return;
      final err = e.toString().toLowerCase();
      final isNetwork = err.contains('network') ||
          err.contains('socket') ||
          err.contains('host lookup') ||
          err.contains('connection');
      AuthMessagePopup.showError(
        context,
        title: isNetwork
            ? 'Impossible de se connecter au serveur.'
            : 'Une erreur est survenue.',
        subtitle: isNetwork ? 'Vérifiez votre connexion internet.' : null,
        buttonText: 'Réessayer',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9FAFB),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8BF13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Choisissez votre pays, puis entrez le numéro national\n(sans répéter l\'indicatif +229).\nLe code part sur le WhatsApp enregistré sur le compte.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      InkWell(
                        onTap: _openCountryPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Text(_phoneCountry.flag),
                              const SizedBox(width: 4),
                              Text(selectedCountryCode ?? '+229'),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _identifierCtrl,
                          keyboardType: TextInputType.phone,
                          maxLength: _maxNationalDigits,
                          onChanged: _onNationalChanged,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Numéro WhatsApp',
                            hintText: 'WhatsApp · ${_phoneCountry.digitHint}',
                            prefixIcon: AuthConfig.whatsAppPhonePrefixIcon(),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            counterText: '',
                          ),
                          validator: (v) {
                            final val = v?.trim() ?? '';
                            if (val.isEmpty) return 'Entrez votre numéro';
                            if (!_phoneCountry.isValidNationalNumber(val)) {
                              return 'Numéro invalide (${_phoneCountry.digitHint})';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFC107)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFF8A6D3B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedCountryCode == '+229'
                                ? 'Ex. pour +229 : saisissez 593XXXXXXX (8 chiffres), pas 01593XXXXXXX ni +229 devant.'
                                : 'Saisissez uniquement le numéro national ; l\'indicatif ${selectedCountryCode ?? '+229'} est déjà choisi.',
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
                      onPressed: _loading ? null : _requestOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8BF13),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text('Envoyer le code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
