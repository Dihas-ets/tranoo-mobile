import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'package:tranoo/utils/api_error_message.dart';
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
  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final pwd = _newPasswordController.text;
    if (!AuthConfig.isPasswordValid(pwd)) {
      AuthMessagePopup.showError(
        context,
        title: l10n.passwordTooShortTitle,
        subtitle: l10n.passwordMinLength(AuthConfig.passwordMinLength),
        buttonText: l10n.ok,
      );
      return;
    }

    if (pwd != _confirmPasswordController.text) {
      AuthMessagePopup.showError(
        context,
        title: l10n.passwordsDoNotMatch,
        buttonText: l10n.ok,
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
          title: result['message']?.toString() ?? l10n.passwordChangedSuccess,
        );
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        AuthMessagePopup.showError(
          context,
          title: ApiErrorMessage.fromMap(l10n, result),
          buttonText: l10n.retry,
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
        title: isNetwork ? l10n.cannotReachServer : l10n.errorOccurredTitle,
        subtitle: isNetwork ? l10n.checkInternet : null,
        buttonText: l10n.retry,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.security),
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
              Text(
                l10n.security,
                style: const TextStyle(fontWeight: FontWeight.w700),
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
                      : Text(
                          l10n.save,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
