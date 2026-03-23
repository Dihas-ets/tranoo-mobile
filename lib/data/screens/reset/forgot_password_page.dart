import 'package:flutter/material.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'package:tranoo/widgets/auth_message_popup.dart';

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

      final fcmToken = await PushOTPService.getFCMToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        if (mounted) {
          AuthMessagePopup.showSupportContact(
            context,
            message: 'Autorisez les notifications pour recevoir le code sur cet appareil.',
            subtitle: 'En cas de difficulté, contactez notre assistance.',
          );
        }
        setState(() => _loading = false);
        return;
      }

      final deviceId = await PushOTPService.getDeviceId();
      if (deviceId == null || deviceId.isEmpty) {
        if (mounted) {
          AuthMessagePopup.showSupportContact(
            context,
            message: "Impossible d'identifier ce téléphone.",
            subtitle: 'Contactez notre assistance pour vous aider.',
          );
        }
        setState(() => _loading = false);
        return;
      }

      final result = await PushOTPService.requestPasswordReset(
        identifier: email,
        deviceId: deviceId,
        fcmToken: fcmToken,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final requestId = result['requestId']?.toString();
        if (requestId == null || requestId.isEmpty) {
          AuthMessagePopup.showSupportContact(
            context,
            message: 'Impossible de démarrer la demande.',
            subtitle: 'Contactez notre assistance pour vous aider.',
          );
          return;
        }
        AuthMessagePopup.showSuccess(
          context,
          title: 'Un lien de réinitialisation a été envoyé à votre email.',
        );
        Navigator.pushNamed(
          context,
          '/auth/verify-reset',
          arguments: {
            'requestId': requestId,
            'deviceId': deviceId,
          },
        );
      } else {
        final msg = result['message'] as String? ?? 'Une erreur est survenue.';
        final needsSupport = msg.toLowerCase().contains('device') ||
            msg.toLowerCase().contains('appareil') ||
            msg.toLowerCase().contains('reconnu') ||
            msg.toLowerCase().contains('identifi') ||
            msg.toLowerCase().contains('compte') && msg.toLowerCase().contains('pas trouvé');
        if (needsSupport || msg.contains('assistance') || msg.contains('support')) {
          AuthMessagePopup.showSupportContact(
            context,
            message: msg,
            subtitle: 'Contactez notre assistance pour vous aider.',
          );
        } else {
          AuthMessagePopup.showError(
            context,
            title: msg.contains('aucun') || msg.contains('pas trouvé')
                ? 'Nous n\'avons trouvé aucun compte avec cet email.'
                : msg,
            buttonText: 'Réessayer',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      final err = e.toString().toLowerCase();
      final isNetwork = err.contains('network') ||
          err.contains('socket') ||
          err.contains('host lookup') ||
          err.contains('connection');
      if (isNetwork) {
        AuthMessagePopup.showError(
          context,
          title: 'Impossible de se connecter au serveur.',
          subtitle: 'Vérifiez votre connexion internet.',
          buttonText: 'Réessayer',
        );
      } else {
        AuthMessagePopup.showSupportContact(
          context,
          message: 'Une erreur est survenue lors de votre demande.',
          subtitle: 'Contactez notre assistance pour vous aider.',
        );
      }
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
                      'Entrez l\'adresse email de votre compte.\nUn code sera envoyé par notification sur ce téléphone.',
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
