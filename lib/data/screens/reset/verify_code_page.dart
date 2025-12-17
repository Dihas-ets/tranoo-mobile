import 'package:flutter/material.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'create_new_password_page.dart';

class VerifyResetCodePage extends StatefulWidget {
  const VerifyResetCodePage({super.key});

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  late final String _telephone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _telephone = (args is String) ? args : '';
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // Vérifier seulement le code OTP, pas le mot de passe
      final result = await PushOTPService.verifyOTPCode(
        telephone: _telephone,
        code: _codeCtrl.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code OTP vérifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Rediriger vers la page de création de mot de passe
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => CreateNewPasswordPage(
                  telephone: _telephone,
                  otpCode: _codeCtrl.text.trim(),
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérifier le code'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8BF13),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8BF13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    () {
                      final phone = _telephone;
                      if (phone.isNotEmpty && phone.length >= 4) {
                        final last4 = phone.substring(phone.length - 4);
                        return 'Un code de vérification vous a été envoyé par message WhatsApp au numéro se terminant par $last4.';
                      }
                      return 'Un code de vérification vous a été envoyé par message WhatsApp sur votre numéro de téléphone.';
                    }(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _codeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'Code de vérification',
                          hintText: 'Entrez le code à 6 chiffres',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          counterText: '',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Veuillez entrer le code';
                          }
                          if (v.trim().length != 6) {
                            return 'Le code doit contenir 6 chiffres';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8BF13),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _loading
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                            : const Text(
                              'Vérifier le code',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
