// CAPTCHA mobile — DÉSACTIVÉ (web uniquement pour l'instant).
// Réactiver via inscription_page.dart quand le mobile sera ciblé.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tranoo/config/turnstile_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Affiche Cloudflare Turnstile dans une WebView et retourne le token.
class TurnstileCaptcha {
  TurnstileCaptcha._();

  static Future<String?> requestToken(BuildContext context) async {
    if (!isTurnstileConfigured) return null;

    final completer = Completer<String?>();
    if (!context.mounted) return null;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        late final WebViewController controller;
        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'CaptchaChannel',
            onMessageReceived: (message) {
              final token = message.message.trim();
              if (token.isEmpty) return;
              if (!completer.isCompleted) completer.complete(token);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          )
          ..loadHtmlString(_html(kTurnstileSiteKey));

        return AlertDialog(
          title: const Text('Contrôle de sécurité'),
          content: SizedBox(
            width: 320,
            height: 120,
            child: WebViewWidget(controller: controller),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!completer.isCompleted) completer.complete(null);
                Navigator.of(ctx).pop();
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (!completer.isCompleted) completer.complete(null);
    return completer.future;
  }

  static String _html(String siteKey) {
    final escaped = siteKey.replaceAll("'", "\\'");
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js?onload=_turnstileCb" async defer></script>
    <style>
      body { margin: 0; display: flex; align-items: center; justify-content: center; min-height: 100px; background: #fff; }
    </style>
  </head>
  <body>
    <div id="cf-turnstile"></div>
    <script>
      function _turnstileCb() {
        turnstile.render('#cf-turnstile', {
          sitekey: '$escaped',
          callback: function(token) {
            CaptchaChannel.postMessage(token);
          },
          'error-callback': function() {
            CaptchaChannel.postMessage('');
          },
          'expired-callback': function() {
            CaptchaChannel.postMessage('');
          }
        });
      }
    </script>
  </body>
</html>
''';
  }
}
