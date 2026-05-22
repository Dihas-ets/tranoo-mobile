import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tranoo/main.dart';
import 'package:tranoo/services/alert_call_payload.dart';
import 'package:tranoo/widgets/alert_incoming_call_overlay.dart';

/// Affiche l'écran appel si [AlertCallActivity] a été ouverte depuis FCM natif.
class AlertLaunchBootstrap extends StatefulWidget {
  final Widget child;

  const AlertLaunchBootstrap({super.key, required this.child});

  @override
  State<AlertLaunchBootstrap> createState() => _AlertLaunchBootstrapState();
}

class _AlertLaunchBootstrapState extends State<AlertLaunchBootstrap> {
  static bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkNativeLaunch());
  }

  Future<void> _checkNativeLaunch() async {
    if (_checked) return;
    _checked = true;
    const channel = MethodChannel('tranoo/alert_launch');
    try {
      final payloadRaw = await channel.invokeMethod<String>('getPayload');
      if (payloadRaw == null || payloadRaw.isEmpty) return;

      Map<String, String> data = {};
      try {
        final decoded = jsonDecode(payloadRaw);
        if (decoded is Map) {
          data = decoded.map(
            (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
          );
        }
      } catch (_) {
        return;
      }

      final title =
          await channel.invokeMethod<String>('getTitle') ?? 'Nouvelle alerte';
      final body = await channel.invokeMethod<String>('getBody') ??
          'Un acheteur recherche un article';

      if (!mounted) return;
      await AlertIncomingCallService.showPayload(
        AlertCallPayload(title: title, body: body, data: data),
        navigatorKey: rootNavigatorKey,
      );
      try {
        await channel.invokeMethod('finishAlert');
      } catch (_) {}
    } catch (_) {
      // MainActivity : pas de payload natif
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
