import 'dart:convert';
import 'dart:core';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart' as flutter_html;
import 'dart:developer' as developer;
import 'package:tranoo/utils/notification_i18n.dart';
import 'package:tranoo/utils/locale_helper.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/data/screens/avant_home.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/services/blocked_user_service.dart';
import 'package:tranoo/services/push_otp_service.dart';
import 'package:tranoo/utils/local_notification_service.dart';
import 'package:tranoo/utils/in_app_delivery_popup.dart';
import 'package:tranoo/services/urgent_fcm_utils.dart';
import 'package:tranoo/services/alert_launch_bootstrap.dart';
import 'package:tranoo/widgets/alert_incoming_call_overlay.dart';
import 'package:tranoo/data/screens/notifications.dart';
import 'package:tranoo/providers/locale_provider.dart';
import 'package:tranoo/utils/feexpay_callback_state.dart';
import 'data/screens/marque.dart';
import 'data/screens/tarif.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as myauth;
import 'providers/counter_provider.dart';
import 'services/cart_service.dart';
import 'package:tranoo/data/screens/reset/forgot_password_page.dart';
import 'package:tranoo/data/screens/reset/verify_code_page.dart';
import 'package:tranoo/data/screens/reset/create_new_password_page.dart';
import 'package:tranoo/data/screens/order_details_page.dart';
import 'package:tranoo/data/screens/mes_commandes.dart';

/// Clés souvent utilisées par FeexPay / le package sur la redirection.
/// Doc V2 (intégrations front) : paramètre **`ref`** sur l’URL de callback.
const List<String> _feexPayTransactionIdKeys = [
  'ref',
  'reference',
  'id_transaction',
  'transaction_id',
  'transactionId',
  'short_code',
  'shortCode',
  'payment_reference',
  'custom_id',
  'order_id',
];

String? _firstNonEmptyFromMap(Map<String, String> map, Iterable<String> keys) {
  for (final k in keys) {
    final v = map[k]?.trim();
    if (v != null && v.isNotEmpty) return v;
  }
  return null;
}

String? _firstNonEmptyFromArgsMap(dynamic args, Iterable<String> keys) {
  if (args is! Map) return null;
  for (final k in keys) {
    final v = args[k]?.toString().trim();
    if (v != null && v.isNotEmpty) return v;
  }
  return null;
}

/// FeexPay / feexpay_flutter peut passer la `reference` UUID en **String** brute dans `RouteSettings.arguments`.
final RegExp _feexFullUuidArg = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
);

String? _feexIdFromRawArguments(dynamic args) {
  if (args == null) return null;
  final fromMap = _firstNonEmptyFromArgsMap(args, _feexPayTransactionIdKeys);
  if (fromMap != null) return fromMap;
  if (args is String) {
    final t = args.trim();
    if (t.isEmpty) return null;
    if (_feexFullUuidArg.hasMatch(t)) return t;
    final trn =
        RegExp(r'\bTRN-[A-Z0-9-]+\b', caseSensitive: false).firstMatch(t);
    if (trn != null) return trn.group(0);
    if (t.startsWith('{') && t.endsWith('}')) {
      try {
        final m = jsonDecode(t);
        if (m is Map)
          return _firstNonEmptyFromArgsMap(m, _feexPayTransactionIdKeys);
      } catch (_) {}
    }
  }
  return null;
}

Map<String, String> _feexQueryParamsFromRouteName(String? name) {
  if (name == null || name.isEmpty) return {};
  final qi = name.indexOf('?');
  if (qi < 0 || qi >= name.length - 1) return {};
  return Uri.splitQueryString(name.substring(qi + 1));
}

/// Logs console + DevTools pour comprendre ce que FeexPay renvoie sur la route.
void _logFeexPayRedirectDebug(RouteSettings? settings, String source) {
  void line(String msg) {
    print('DEBUG_FEEEXPAY[$source] $msg');
    developer.log(msg, name: 'DEBUG_FEEEXPAY');
  }

  if (settings == null) {
    line('settings=null');
    return;
  }

  final name = settings.name;
  line('Route name brut: $name');
  line(
      'arguments type=${settings.arguments?.runtimeType} valeur=${settings.arguments}');

  final qpSplit = _feexQueryParamsFromRouteName(name);
  if (qpSplit.isNotEmpty) {
    line('Query (Uri.splitQueryString): $qpSplit');
  } else {
    line('Aucune query string après ? sur le route name');
  }

  if (name != null && name.isNotEmpty) {
    try {
      final uri = name.contains('://')
          ? Uri.parse(name)
          : Uri.parse('https://feexpay.redirect.debug$name');
      line('Uri.parse queryParameters: ${uri.queryParameters}');
    } catch (e) {
      line('Uri.parse échoué: $e');
    }
  }

  final fromArgs = _feexIdFromRawArguments(settings.arguments);
  final fromQuery = _firstNonEmptyFromMap(qpSplit, _feexPayTransactionIdKeys);
  line(
    'ID déduit (priorité args puis query): ${fromArgs ?? fromQuery ?? "(aucun)"}',
  );
}

/// Extrait l’identifiant FeexPay (UUID ou short code) depuis la route de retour.
String? _feexIdFromRouteSettings(RouteSettings? settings) {
  if (settings == null) return null;
  final fromArgs = _feexIdFromRawArguments(settings.arguments);
  if (fromArgs != null) return fromArgs;

  final name = settings.name;
  final qp = _feexQueryParamsFromRouteName(name);
  final fromQuery = _firstNonEmptyFromMap(qp, _feexPayTransactionIdKeys);
  if (fromQuery != null) return fromQuery;

  if (name != null && name.isNotEmpty) {
    try {
      final uri = name.contains('://')
          ? Uri.parse(name)
          : Uri.parse('https://feexpay.redirect.debug$name');
      final fromUri = _firstNonEmptyFromMap(
        uri.queryParameters,
        _feexPayTransactionIdKeys,
      );
      if (fromUri != null) return fromUri;
    } catch (_) {}
  }
  return null;
}

// Gestionnaire pour les notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logger('FCM').info('Message reçu en arrière-plan: ${message.messageId}');
  if (isUrgentFcmMessage(message)) {
    await LocalNotificationService.initialize();
    final locale = await LocaleHelper.storedLanguageCode();
    final push = NotificationI18n.resolvePush(
      message,
      locale,
      defaultTitle: 'Nouvelle proposition',
    );
    final data = message.data.map(
      (k, v) => MapEntry(k, v?.toString() ?? ''),
    );
    await LocalNotificationService.showAlertIncomingCallNotification(
      title: push.title,
      body: push.body,
      data: data,
    );
  }
}

// Service pour gérer les notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Logger _logger = Logger('NotificationService');

  Future<void> initialize() async {
    try {
      // Demander les permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.info('Permissions accordées: ${settings.authorizationStatus}');

      // Configurer le gestionnaire de messages en arrière-plan
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Gestionnaire pour les messages en premier plan
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.info(
          'Message reçu en premier plan: ${message.notification?.title}',
        );
        if (isUrgentFcmMessage(message)) {
          AlertIncomingCallService.show(
            message,
            navigatorKey: rootNavigatorKey,
          );
          return;
        }
        _showLocalNotification(message);
      });

      // Gestionnaire pour les notifications cliquées
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.info('Notification cliquée: ${message.notification?.title}');
        if (isUrgentFcmMessage(message)) {
          _openUrgentNotificationFromTap(message);
          return;
        }
        _handleNotificationTap(message);
      });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null && isUrgentFcmMessage(initialMessage)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openUrgentNotificationFromTap(initialMessage);
        });
      }

      // Récupérer le token FCM
      String? token = await _messaging.getToken();
      if (token != null) {
        _logger.info('Token FCM: $token');
        await _sendTokenToBackend(token);
      }

      // Écouter les changements de token
      _messaging.onTokenRefresh.listen((newToken) {
        _logger.info('Nouveau token FCM: $newToken');
        _sendTokenToBackend(newToken);
      });
    } catch (e) {
      _logger.severe('Erreur lors de l\'initialisation FCM: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.warning('Utilisateur non connecté, token non envoyé');
        return;
      }

      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse('${getBaseUrl().replaceAll('/api', '')}/api/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        _logger.info('Token FCM envoyé au backend avec succès');
      } else {
        _logger.warning(
          'Erreur lors de l\'envoi du token: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.severe('Erreur lors de l\'envoi du token au backend: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    _logger.info('Notification locale: ${message.notification?.title}');

    // Popup global (in-app) pour arrivée livreur (peu importe l'écran)
    if (message.data['type'] == 'delivery' &&
        (message.data['eventType'] == 'arrived' ||
            message.data['eventType'] == 'arrived'.toString()) &&
        message.data['relatedId'] != null) {
      final deliveryId = message.data['relatedId'].toString();
      InAppDeliveryPopup.showLivreurArrived(deliveryId: deliveryId);
    }

    // Afficher une notification locale visible même en foreground
    if (message.data['type'] == 'otp') {
      final code = message.data['code'] as String?;
      if (code != null && code.isNotEmpty) {
        LocalNotificationService.showOTPNotification(code);
      } else {
        final body = message.notification?.body ?? '';
        final match = RegExp(r'(\d{6})').firstMatch(body);
        if (match != null) {
          LocalNotificationService.showOTPNotification(match.group(1)!);
        }
      }
    } else {
      final locale = await LocaleHelper.storedLanguageCode();
      final push = NotificationI18n.resolvePush(message, locale);
      if (message.data['type'] == 'tricycle') {
        LocalNotificationService.showTricycleNotification(
          push.title,
          push.body,
        );
      } else {
        LocalNotificationService.showNotification(
          push.title,
          push.body,
        );
      }
    }
  }

  void _openUrgentNotificationFromTap(RemoteMessage message) {
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const Notifications()),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigation vers une page spécifique selon le type de notification
    _logger.info(
      'Gestion du tap sur notification: ${message.notification?.title}',
    );

    // Exemple de navigation selon le type de notification
    if (message.data.containsKey('type')) {
      final type = message.data['type'];
      final eventType = message.data['eventType'];
      if (type == 'delivery' &&
          eventType == 'arrived' &&
          message.data['relatedId'] != null) {
        final deliveryId = message.data['relatedId'].toString();
        InAppDeliveryPopup.showLivreurArrived(deliveryId: deliveryId);
        return;
      }

      switch (type) {
        case 'chat':
          _logger.info('Navigation vers chat: ${message.data['roomId']}');
          break;
        case 'publicite':
          _logger.info('Navigation vers publicités');
          break;
        case 'article':
          _logger.info('Navigation vers articles');
          break;
        case 'system':
          _logger.info('Notification système: ${message.notification?.body}');
          break;
        default:
          _logger.info('Navigation par défaut');
          break;
      }
    }
  }
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");

  // Initialiser le service de notifications locales
  try {
    await LocalNotificationService.initialize();
    print('LocalNotificationService initialisé');
  } catch (e) {
    print('Erreur LocalNotificationService: $e');
  }

  // Initialiser le service de notifications
  await NotificationService().initialize();

  // Initialiser le service OTP Push
  await PushOTPService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => myauth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Navigator global pour afficher des popups depuis n'importe où (FCM)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'Tranoo',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      locale: localeProvider.locale ?? DevicePreview.locale(context),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        // Définir le contexte pour BlockedUserService
        WidgetsBinding.instance.addPostFrameCallback((_) {
          BlockedUserService.setContext(context);
        });
        return AlertLaunchBootstrap(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(),
            child: DevicePreview.appBuilder(context, child),
          ),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AvantHome(),
      routes: {
        '/marque': (context) => const Marque(),
        '/subscription-success': (context) => _buildSubscriptionSuccessPage(),
        '/subscription-error': (context) => _buildSubscriptionErrorPage(),
        '/verification-success': (context) =>
            const _CartPaymentCallbackPage(success: true),
        '/verification-error': (context) =>
            const _CartPaymentCallbackPage(success: false),
        '/tarif': (context) => const Tarif(),
        '/auth/forgot-password': (context) => const ForgotPasswordPage(),
        '/auth/verify-reset': (context) => const VerifyResetCodePage(),
        '/auth/create-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return CreateNewPasswordPage(
            requestId: args?['requestId'] ?? '',
            deviceId: args?['deviceId'] ?? '',
          );
        },
        '/orders': (context) => const MesCommandesPage(),
        '/order-details': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return OrderDetailsPage(
            order: args?['order'] ?? {},
            accentColor: args?['accentColor'] ?? const Color(0xFF1F69FF),
          );
        },
        '/cart-payment-success': (context) =>
            const _CartPaymentCallbackPage(success: true),
        '/cart-payment-error': (context) =>
            const _CartPaymentCallbackPage(success: false),
      },
    );
  }
}

class _CartPaymentCallbackPage extends StatefulWidget {
  final bool success;
  const _CartPaymentCallbackPage({required this.success});

  @override
  State<_CartPaymentCallbackPage> createState() =>
      _CartPaymentCallbackPageState();
}

class _CartPaymentCallbackPageState extends State<_CartPaymentCallbackPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool _handled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handled) return;
    _handled = true;
    developer.log(
      '[FEEPAY_CALLBACK] route hit success=${widget.success} args=${ModalRoute.of(context)?.settings.arguments}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Retourner le résultat au ChoicePage qui a pushNamed ce callback.
      final settings = ModalRoute.of(context)?.settings;
      _logFeexPayRedirectDebug(
        settings,
        widget.success ? 'cart_payment_success' : 'cart_payment_error',
      );
      final feexId = _feexIdFromRouteSettings(settings);
      FeexPayCallbackState.report(
        success: widget.success,
        args: feexId ?? settings?.arguments?.toString(),
        transactionId: feexId,
      );
      final payload = <String, dynamic>{
        'success': widget.success,
        'successHint': widget.success,
        'routeName': settings?.name,
        'callbackArgs': settings?.arguments?.toString(),
        if (feexId != null && feexId.isNotEmpty) 'id_transaction': feexId,
        if (feexId != null && feexId.isNotEmpty) 'ref': feexId,
        if (feexId != null && feexId.isNotEmpty) 'reference': feexId,
      };
      developer.log(
          '[FEEPAY_CALLBACK] pop callback payload=$payload feexId=$feexId');
      Navigator.of(context).pop(payload);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: widget.success ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

// Gestion du succès de paiement d'abonnement
Widget _buildSubscriptionSuccessPage() {
  return SubscriptionSuccessPage();
}

// Gestion de l'échec de paiement d'abonnement
Widget _buildSubscriptionErrorPage() {
  return SubscriptionErrorPage();
}

// Gestion du succès de paiement de vérification
Widget _buildVerificationSuccessPage() {
  return VerificationSuccessPage();
}

// Gestion de l'échec de paiement de vérification
Widget _buildVerificationErrorPage() {
  return VerificationErrorPage();
}

class SubscriptionSuccessPage extends StatefulWidget {
  @override
  _SubscriptionSuccessPageState createState() =>
      _SubscriptionSuccessPageState();
}

class _SubscriptionSuccessPageState extends State<SubscriptionSuccessPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  bool _handled = false;

  Future<num> _resolveSubscriptionAmount() async {
    try {
      final pricingResponse = await http.get(
        Uri.parse('${getBaseUrl()}/admin/subscription-pricing'),
      );
      if (pricingResponse.statusCode == 200) {
        final data = jsonDecode(pricingResponse.body);
        final direct =
            data is Map<String, dynamic> ? data['prixMensuel'] : null;
        if (direct is num && direct > 0) return direct;
        final nested = data is Map<String, dynamic> &&
                data['pricing'] is Map<String, dynamic>
            ? data['pricing']['prixMensuel']
            : null;
        if (nested is num && nested > 0) return nested;
      }
    } catch (_) {}
    return 5000;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handled) return;
    _handled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleSubscriptionSuccess();
    });
  }

  Future<void> _handleSubscriptionSuccess() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      final subscriptionAmount = await _resolveSubscriptionAmount();
      final settings = ModalRoute.of(context)?.settings;
      _logFeexPayRedirectDebug(settings, 'subscription_success');
      final feexId = _feexIdFromRouteSettings(settings);

      if (feexId != null && feexId.isNotEmpty) {
        final statusResp = await http.get(
          Uri.parse(
            '${getBaseUrl()}/payments/feexpay/public/status/$feexId',
          ),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (statusResp.statusCode == 200) {
          final body = jsonDecode(statusResp.body);
          final st =
              (body is Map ? body['status'] : null)?.toString().toLowerCase() ??
                  '';
          final ok = st.contains('success') ||
              st.contains('successful') ||
              st.contains('paid') ||
              st.contains('ok') ||
              st.contains('completed') ||
              st.contains('approved');
          if (!ok) {
            print(
              '[SUBSCRIPTION_SUCCESS] statut FeexPay non confirmé: $st ref=$feexId',
            );
          }
        }
      } else {
        print(
          '[SUBSCRIPTION_SUCCESS] aucun id_transaction dans la route — enregistrement legacy',
        );
      }

      // 1. Enregistrer le paiement
      final paymentResponse = await http.post(
        Uri.parse('${getBaseUrl()}/payments/feexpay/flutter/record'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transKey': 'SUBSCRIPTION_${DateTime.now().millisecondsSinceEpoch}',
          'amount': subscriptionAmount,
          'description': 'Abonnement Premium Transitaire - 1 mois',
          'type': 'subscription',
          'status': 'success',
          if (feexId != null && feexId.isNotEmpty) 'id_transaction': feexId,
          if (feexId != null && feexId.isNotEmpty) 'ref': feexId,
          if (feexId != null && feexId.isNotEmpty) 'reference': feexId,
        }),
      );
      print(
        'Paiement enregistré: ${paymentResponse.statusCode} - ${paymentResponse.body}',
      );

      // 2. Activer l'abonnement
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/subscription/subscribe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'plan': 'monthly'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Abonnement activé avec succès');
      }
    } catch (e) {
      print('Erreur activation abonnement: $e');
    }

    // Redirection après 2 secondes
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/tarif', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFFCC00)),
            SizedBox(height: 16),
            Text('Activation de votre abonnement...'),
            SizedBox(height: 8),
            Text(
              'Redirection automatique vers vos tarifs',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Paiement échoué',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/tarif', (route) => false),
              child: Text('Retourner aux tarifs'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationSuccessPage extends StatefulWidget {
  @override
  _VerificationSuccessPageState createState() =>
      _VerificationSuccessPageState();
}

class _VerificationSuccessPageState extends State<VerificationSuccessPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String? htmlContent;

  @override
  void initState() {
    super.initState();
    _loadAndShow();
  }

  Future<void> _loadAndShow() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _logFeexPayRedirectDebug(
        ModalRoute.of(context)?.settings,
        'verification_success',
      );
    });
    try {
      htmlContent = await DefaultAssetBundle.of(context)
          .loadString('assets/html/verification_success.html');
    } catch (_) {
      htmlContent = null;
    }
    setState(() {});
    await Future.delayed(const Duration(seconds: 2));
    if (mounted)
      Navigator.of(context).pop(true); // retourner à l'écran appelant
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: htmlContent != null
              ? SingleChildScrollView(
                  child: flutter_html.Html(data: htmlContent))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    SizedBox(height: 16),
                    Text('Paiement réussi',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Redirection en cours...',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }
}

class VerificationErrorPage extends StatefulWidget {
  @override
  State<VerificationErrorPage> createState() => _VerificationErrorPageState();
}

class _VerificationErrorPageState extends State<VerificationErrorPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String? htmlContent;

  @override
  void initState() {
    super.initState();
    _loadAndShow();
  }

  Future<void> _loadAndShow() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _logFeexPayRedirectDebug(
        ModalRoute.of(context)?.settings,
        'verification_error',
      );
    });
    try {
      htmlContent = await DefaultAssetBundle.of(context)
          .loadString('assets/html/verification_error.html');
    } catch (_) {
      htmlContent = null;
    }
    setState(() {});
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: htmlContent != null
              ? SingleChildScrollView(
                  child: flutter_html.Html(data: htmlContent))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.error, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text('Paiement échoué',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Redirection en cours...',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    // Attendre un peu pour que le contexte soit disponible
    await Future.delayed(const Duration(milliseconds: 500));

    // Définir le contexte pour BlockedUserService
    BlockedUserService.setContext(context);

    // Vérifier le statut de blocage
    final userService = UserService();
    final isBlocked = await userService.checkUserBlockedStatus();

    if (isBlocked) {
      // L'utilisateur est bloqué, le dialogue sera affiché automatiquement
      return;
    }

    // Détecter le code de parrainage depuis l'URL
    await _handleReferralCode();

    // Naviguer vers l'écran principal
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AvantHome()),
      );
    }
  }

  Future<void> _handleReferralCode() async {
    try {
      // Vérifier s'il y a un code de parrainage en attente
      final prefs = await SharedPreferences.getInstance();
      final pendingReferral = prefs.getString('pending_referral');

      if (pendingReferral != null && pendingReferral.isNotEmpty) {
        print('Code de parrainage en attente: $pendingReferral');

        // Afficher une notification HTML standard
        if (mounted) {
          _showReferralNotification(pendingReferral);
        }
      }
    } catch (e) {
      print('Erreur lors de la détection du parrainage: $e');
    }
  }

  void _showReferralNotification(String referralCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.amber[700], size: 28),
              SizedBox(width: 10),
              Text(
                'Code de Parrainage Détecté',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.celebration,
                        color: Colors.amber[700],
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Félicitations !',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vous avez été invité par un ami avec le code:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          referralCode,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Ce code sera automatiquement appliqué lors de votre inscription.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Compris',
                style: TextStyle(
                  color: Colors.amber[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
