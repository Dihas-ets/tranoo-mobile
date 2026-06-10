import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'package:tranoo/utils/api_error_message.dart';
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

    final l10n = AppLocalizations.of(context)!;
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
          title: l10n.missingInfoTitle,
          subtitle: l10n.restartFromForgotPassword,
          buttonText: l10n.ok,
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

  String? _validateCode(AppLocalizations l10n) {
    final code = _effectiveCode;
    if (code.isEmpty) return l10n.enterCodePlease;
    if (!AuthConfig.otpPattern.hasMatch(code)) {
      return l10n.otpMustBe6Digits;
    }
    return null;
  }

  Future<void> _verifyCode() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context)!;
    _code = _effectiveCode;
    final err = _validateCode(l10n);
    if (err != null) {
      AuthMessagePopup.showError(context, title: err, buttonText: l10n.ok);
      return;
    }

    if (_requestId.isEmpty || _deviceId.isEmpty) {
      AuthMessagePopup.showError(
        context,
        title: l10n.missingInfoTitle,
        subtitle: l10n.restartFromForgotPassword,
        buttonText: l10n.ok,
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
        AuthMessagePopup.showError(
          context,
          title: ApiErrorMessage.fromMap(l10n, result),
          buttonText: l10n.retry,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AuthMessagePopup.showError(
        context,
        title: l10n.errorOccurredTitle,
        subtitle: l10n.checkConnectionAndRetry,
        buttonText: l10n.retry,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final validityMinutes = (_expiresInSeconds / 60).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyCodeTitle),
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
                    l10n.verifyCodeBanner(validityMinutes),
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
                        : Text(
                            l10n.verifyCodeTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
