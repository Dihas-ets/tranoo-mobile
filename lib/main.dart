import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'data/screens/first_page.dart';
import 'data/screens/marque.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart' as myauth;
import 'package:tranoo/data/screens/avant_home.dart';
import 'package:tranoo/services/user_service.dart';

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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialiser le service de notifications
  await NotificationService().initialize();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => myauth.AuthProvider())],
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
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(),
          child: DevicePreview.appBuilder(context, child),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AvantHome(),
      routes: {
        '/marque': (context) => const Marque(),
        '/first': (context) => const FirstPage(),
      },
    );
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