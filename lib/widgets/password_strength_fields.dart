import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/auth_config.dart';

/// Champs mot de passe + confirmation avec jauge (étape « Sécurité » de l'inscription).
class PasswordStrengthFields extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  const PasswordStrengthFields({
    super.key,
    required this.passwordController,
    required this.confirmController,
  });

  @override
  State<PasswordStrengthFields> createState() => _PasswordStrengthFieldsState();
}

class _PasswordStrengthFieldsState extends State<PasswordStrengthFields> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_onPasswordChanged);
    _onPasswordChanged();
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  String _localizedStrengthLabel(AppLocalizations l10n, double score) {
    if (score == 0) return '';
    if (score < 0.4) return l10n.passwordWeak;
    if (score < 0.7) return l10n.passwordMedium;
    if (score < 0.9) return l10n.passwordStrong;
    return l10n.passwordVeryStrong;
  }

  void _onPasswordChanged() {
    final l10n = AppLocalizations.of(context)!;
    final r = AuthConfig.evaluatePasswordStrength(widget.passwordController.text);
    setState(() {
      _passwordStrength = r.score;
      _passwordStrengthLabel = _localizedStrengthLabel(l10n, r.score);
      _passwordStrengthColor = r.color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Focus(
          onFocusChange: (_) => setState(() {}),
          child: TextField(
            controller: widget.passwordController,
            onChanged: (_) => _onPasswordChanged(),
            obscureText: _obscurePassword,
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
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
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
        const SizedBox(height: 8),
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
              const SizedBox(height: 6),
              Text(
                l10n.passwordStrengthLabel(_passwordStrengthLabel),
                style: TextStyle(
                  color: _passwordStrengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        Focus(
          onFocusChange: (_) => setState(() {}),
          child: TextField(
            controller: widget.confirmController,
            obscureText: _obscureConfirm,
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
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
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
      ],
    );
  }
}
