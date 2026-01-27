import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'dart:async';

class VerifyResetCodePage extends StatefulWidget {
  const VerifyResetCodePage({super.key});

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  late final String _requestId;
  late final String _deviceId;
  StreamSubscription<RemoteMessage>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    // Écouter les notifications pour auto-remplir le code OTP
    _notificationSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'otp' && mounted) {
        // Extraire le code depuis data.code (prioritaire) ou depuis notification.body
        String? code = message.data['code'] as String?;
        if (code == null || code.isEmpty) {
          // Fallback: extraire depuis notification.body (format: "Votre code : 123456")
          final body = message.notification?.body ?? '';
          final match = RegExp(r'(\d{6})').firstMatch(body);
          code = match?.group(1);
        }
        
        if (code != null && code.isNotEmpty && _codeCtrl.text.isEmpty) {
          setState(() {
            _codeCtrl.text = code!;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Code OTP reçu : $code'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _requestId = (args['requestId'] as String?) ?? '';
      _deviceId = (args['deviceId'] as String?) ?? '';
    } else {
      _requestId = '';
      _deviceId = '';
    }
    
    // Vérifier que les arguments requis sont présents
    if (_requestId.isEmpty || _deviceId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Informations manquantes. Veuillez recommencer.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Vérifier que les arguments requis sont présents
    if (_requestId.isEmpty || _deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations manquantes. Veuillez recommencer.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    
    setState(() => _loading = true);
    try {
      final result = await PushOTPService.verifyResetCode(
        requestId: _requestId,
        deviceId: _deviceId,
        code: _codeCtrl.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ?? 'Code vérifié'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamed(
          context,
          '/auth/create-password',
          arguments: {
            'requestId': _requestId,
            'deviceId': _deviceId,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ?? 'Erreur'),
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
                    'Un code vous a été envoyé par notification push sur cet appareil. Saisissez-le ci-dessous.',
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
                    onPressed: _loading ? null : _verifyCode,
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
