import 'package:flutter/material.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'package:tranoo/utils/auth_config.dart';
import 'package:tranoo/widgets/auth_message_popup.dart';

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
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

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
        subtitle:
            'Minimum ${AuthConfig.passwordMinLength} caractères (comme à l\'inscription).',
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
        AuthMessagePopup.showSuccess(
          context,
          title: result['message']?.toString() ??
              'Mot de passe modifié avec succès.',
        );
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
      if (isNetwork) {
        AuthMessagePopup.showError(
          context,
          title: 'Impossible de se connecter au serveur.',
          subtitle: 'Vérifiez votre connexion internet.',
          buttonText: 'Réessayer',
        );
      } else {
        AuthMessagePopup.showError(
          context,
          title: 'Une erreur est survenue.',
          subtitle: 'Veuillez réessayer.',
          buttonText: 'Réessayer',
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
        title: const Text('Créer un nouveau mot de passe'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Créez un nouveau mot de passe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum ${AuthConfig.passwordMinLength} caractères (même règle qu\'à l\'inscription).',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  hintText: 'Min. ${AuthConfig.passwordMinLength} caractères',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (!AuthConfig.isPasswordValid(value)) {
                    return 'Au moins ${AuthConfig.passwordMinLength} caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmer mot de passe',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer le mot de passe';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createNewPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8BF13),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
