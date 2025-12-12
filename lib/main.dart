import 'dart:convert';
import 'dart:core';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart' as flutter_html;
import 'package:tranoo/data/screens/avant_home.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/services/blocked_user_service.dart';
import 'package:tranoo/services/push_otp_service.dart';

// import 'package:flutter/services.dart';
import 'data/screens/marque.dart';
import 'data/screens/tarif.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as myauth;
import 'providers/counter_provider.dart';
import 'services/cart_service.dart';
import 'package:tranoo/data/screens/reset/forgot_password_page.dart';
import 'package:tranoo/data/screens/reset/verify_code_page.dart';
import 'package:tranoo/data/screens/reset/create_new_password_page.dart';

// Gestionnaire pour les notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logger('FCM').info('Message reçu en arrière-plan: ${message.messageId}');
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
        _showLocalNotification(message);
      });

      // Gestionnaire pour les notifications cliquées
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.info('Notification cliquée: ${message.notification?.title}');
        _handleNotificationTap(message);
      });

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

  void _showLocalNotification(RemoteMessage message) {
    // Améliorer l'affichage des notifications locales
    _logger.info('Notification locale: ${message.notification?.title}');

    // Ici tu peux ajouter une notification locale avec flutter_local_notifications
    // si tu veux afficher des notifications même quand l'app est en premier plan
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigation vers une page spécifique selon le type de notification
    _logger.info(
      'Gestion du tap sur notification: ${message.notification?.title}',
    );

    // Exemple de navigation selon le type de notification
    if (message.data.containsKey('type')) {
      switch (message.data['type']) {
        case 'chat':
          // Naviguer vers la page de chat spécifique
          _logger.info('Navigation vers chat: ${message.data['roomId']}');
          break;
        case 'publicite':
          // Naviguer vers la page des publicités
          _logger.info('Navigation vers publicités');
          break;
        case 'article':
          // Naviguer vers la page des articles
          _logger.info('Navigation vers articles');
          break;
        case 'system':
          // Notification système
          _logger.info('Notification système: ${message.notification?.body}');
          break;
        default:
          // Navigation par défaut
          _logger.info('Navigation par défaut');
          break;
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tranoo',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        // Définir le contexte pour BlockedUserService
        WidgetsBinding.instance.addPostFrameCallback((_) {
          BlockedUserService.setContext(context);
        });
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(),
          child: DevicePreview.appBuilder(context, child),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppInitializer(),
      routes: {
        '/marque': (context) => const Marque(),
        '/subscription-success': (context) => _buildSubscriptionSuccessPage(),
        '/subscription-error': (context) => _buildSubscriptionErrorPage(),
        '/verification-success': (context) => _buildVerificationSuccessPage(),
        '/verification-error': (context) => _buildVerificationErrorPage(),
        '/tarif': (context) => const Tarif(),
        '/auth/forgot-password': (context) => const ForgotPasswordPage(),
        '/auth/verify-reset': (context) => const VerifyResetCodePage(),
        '/auth/create-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return CreateNewPasswordPage(
            telephone: args?['telephone'] ?? '',
            otpCode: args?['otpCode'] ?? '',
          );
        },
      },
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
  @override
  void initState() {
    super.initState();
    _handleSubscriptionSuccess();
  }

  Future<void> _handleSubscriptionSuccess() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();

      // 1. Enregistrer le paiement
      final paymentResponse = await http.post(
        Uri.parse('${getBaseUrl()}/payments/feexpay/flutter/record'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transKey': 'SUBSCRIPTION_${DateTime.now().millisecondsSinceEpoch}',
          'amount': 5,
          'description': 'Abonnement Premium Transitaire - 1 mois',
          'type': 'subscription',
          'status': 'success',
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
  String? htmlContent;

  @override
  void initState() {
    super.initState();
    _loadAndShow();
  }

  Future<void> _loadAndShow() async {
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
  String? htmlContent;

  @override
  void initState() {
    super.initState();
    _loadAndShow();
  }

  Future<void> _loadAndShow() async {
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

/*void main() {
  runApp(const MyApp());
}*/

/*class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirstPage(),
    );
  }
}*/

// import 'package:flutter/material.dart';
// import 'nouveau.dart'; // adapte le chemin si besoin

// void main() {
//   runApp(const MaterialApp(
//     home: AgePickerPage(),
//     debugShowCheckedModeBanner: false,
//   ));
// }
