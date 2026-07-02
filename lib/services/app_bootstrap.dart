import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/utils/onboarding_prefs.dart';

/// Travail de démarrage sans UI — exécuté avant [runApp] pour éviter l'écran blanc.
class AppBootstrap {
  AppBootstrap._();

  static Future<void>? _warmFuture;
  static SharedPreferences? prefs;
  static bool? onboardingComplete;

  static Future<void> warmUp() {
    return _warmFuture ??= _run();
  }

  static Future<void> _run() async {
    prefs = await SharedPreferences.getInstance();
    onboardingComplete = prefs!.getBool(kOnboardingCompleteKey) ?? false;
  }
}
