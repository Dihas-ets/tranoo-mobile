import 'package:flutter/material.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'package:tranoo/utils/auth_config.dart';
import 'package:tranoo/widgets/auth_message_popup.dart';
import 'package:tranoo/widgets/password_strength_fields.dart';

class CreateNewPasswordPage extends StatefulWidget {
  final String requestId;
  final String deviceId;

  const CreateNewPasswordPage({
    super.key,
    required this.requestId,
    required this.deviceId,
  });

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final pwd = _newPasswordController.text;
    if (!AuthConfig.isPasswordValid(pwd)) {
      AuthMessagePopup.showError(
        context,
        title: 'Mot de passe trop court.',
        subtitle: 'Minimum ${AuthConfig.passwordMinLength} caractères.',
        buttonText: 'OK',
      );
      return;
    }

    if (pwd != _confirmPasswordController.text) {
      AuthMessagePopup.showError(
        context,
        title: 'Les mots de passe ne correspondent pas.',
        buttonText: 'OK',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await PushOTPService.resetPassword(
        requestId: widget.requestId,
        deviceId: widget.deviceId,
        newPassword: pwd,
      );

      if (!mounted) return;

      if (result['success']) {
        await AuthMessagePopup.showSuccess(
          context,
          title: result['message']?.toString() ??
              'Mot de passe modifié avec succès.',
        );
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        AuthMessagePopup.showError(
          context,
          title: result['message']?.toString() ?? 'Une erreur est survenue.',
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9FAFB),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8BF13),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8BF13),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Sécurité',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: screenHeight * 0.02),
              PasswordStrengthFields(
                passwordController: _newPasswordController,
                confirmController: _confirmPasswordController,
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createNewPassword,
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
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
