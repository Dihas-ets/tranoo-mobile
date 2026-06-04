import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'package:tranoo/utils/auth_config.dart';
import 'package:tranoo/widgets/auth_message_popup.dart';
import 'package:tranoo/widgets/otp_pin_input.dart';

class VerifyResetCodePage extends StatefulWidget {
  const VerifyResetCodePage({super.key});

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _pinKey = GlobalKey<OtpPinInputState>();
  String _code = '';
  bool _loading = false;
  bool _argsLoaded = false;
  String _requestId = '';
  String _deviceId = '';
  int _expiresInSeconds = AuthConfig.otpValiditySeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PushOTPService.pendingOtpCode.addListener(_onPendingOtpFromPush);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onPendingOtpFromPush();
      _tryClipboardOtp();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _requestId = (args['requestId'] as String?) ?? '';
      _deviceId = (args['deviceId'] as String?) ?? '';
      final exp = args['expiresInSeconds'];
      if (exp is num && exp > 0) _expiresInSeconds = exp.toInt();
      final initialOtp = args['initialOtp'] as String?;
      if (initialOtp != null && initialOtp.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _applyOtpCode(initialOtp);
        });
      }
    }

    if (_requestId.isEmpty || _deviceId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AuthMessagePopup.showError(
          context,
          title: 'Informations manquantes.',
          subtitle: 'Veuillez recommencer depuis la page mot de passe oublié.',
          buttonText: 'OK',
        ).then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PushOTPService.pendingOtpCode.removeListener(_onPendingOtpFromPush);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryClipboardOtp();
    }
  }

  void _onPendingOtpFromPush() {
    final code = PushOTPService.pendingOtpCode.value;
    if (code != null) _applyOtpCode(code);
  }

  void _applyOtpCode(String code) {
    final trimmed = code.trim();
    if (!AuthConfig.otpPattern.hasMatch(trimmed)) return;
    if (_code == trimmed) return;
    if (!mounted) return;
    _code = trimmed;
    setState(() {});
    _pinKey.currentState?.setCode(trimmed);
  }

  String get _effectiveCode =>
      _pinKey.currentState?.value ?? _code;

  Future<void> _tryClipboardOtp() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) return;
      final match = RegExp(r'\b(\d{6})\b').firstMatch(text);
      if (match != null) _applyOtpCode(match.group(1)!);
    } catch (_) {}
  }

  String? _validateCode() {
    final code = _effectiveCode;
    if (code.isEmpty) return 'Veuillez entrer le code';
    if (!AuthConfig.otpPattern.hasMatch(code)) {
      return 'Le code doit contenir 6 chiffres';
    }
    return null;
  }

  Future<void> _verifyCode() async {
    if (_loading) return;
    _code = _effectiveCode;
    final err = _validateCode();
    if (err != null) {
      AuthMessagePopup.showError(context, title: err, buttonText: 'OK');
      return;
    }

    if (_requestId.isEmpty || _deviceId.isEmpty) {
      AuthMessagePopup.showError(
        context,
        title: 'Informations manquantes.',
        subtitle: 'Veuillez recommencer depuis la page mot de passe oublié.',
        buttonText: 'OK',
      ).then((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await PushOTPService.verifyResetCode(
        requestId: _requestId,
        deviceId: _deviceId,
        code: _effectiveCode,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushReplacementNamed(
          context,
          '/auth/create-password',
          arguments: {
            'requestId': _requestId,
            'deviceId': _deviceId,
          },
        );
      } else {
        final msg = result['message'] as String? ?? 'Code invalide.';
        AuthMessagePopup.showError(
          context,
          title: msg,
          buttonText: 'Réessayer',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AuthMessagePopup.showError(
        context,
        title: 'Une erreur est survenue.',
        subtitle: 'Vérifiez votre connexion et réessayez.',
        buttonText: 'Réessayer',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _validityHint {
    final min = (_expiresInSeconds / 60).ceil();
    return 'Valide $min min. Vérifiez la notification Tranoo ou WhatsApp au numéro du compte.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérifier le code'),
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
                  child: Text(
                    'Saisissez le code à 6 chiffres.\n$_validityHint',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: OtpPinInput(
                    key: _pinKey,
                    length: AuthConfig.otpLength,
                    onChanged: (v) => _code = v,
                    onCompleted: () {
                      if (!_loading) _verifyCode();
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8BF13),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
