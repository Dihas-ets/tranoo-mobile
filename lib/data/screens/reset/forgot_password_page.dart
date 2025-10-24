import 'package:flutter/material.dart';
import 'package:tranoo/services/push_otp_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _emailCtrl.text.trim();

      // D'abord récupérer le numéro de téléphone via l'email
      final phoneResult = await PushOTPService.getPhoneByEmail(email);

      if (!phoneResult['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(phoneResult['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _loading = false);
        return;
      }

      final phoneNumber = phoneResult['phoneNumber'];

      // Envoyer l'OTP au numéro récupéré
      final result = await PushOTPService.requestOTP(phoneNumber);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamed(
          context,
          '/auth/verify-reset',
          arguments: phoneNumber,
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
                  // Bande jaune pleine largeur
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
                      'Entrez votre email pour recevoir un code par notification push.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Champ email
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Adresse email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    ),
                    validator: (v) {
                      final val = v?.trim() ?? '';
                      if (val.isEmpty) return 'Entrez votre email';
                      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!regex.hasMatch(val)) {
                        return 'Format email invalide';
                      }
                      return null;
                    },
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
