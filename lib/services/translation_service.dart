import 'package:dio/dio.dart';

class TranslationService {
  // Utilisation de MyMemory API (vraiment gratuite)
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';
  
  static final Dio _dio = Dio();

  // Liste des langues supportées
  static const Map<String, String> supportedLanguages = {
    'fr': 'Français',
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
    'it': 'Italiano',
  };

  static Future<String> translate(String text, String sourceLang, String targetLang) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'q': text,
          'langpair': '${sourceLang}|${targetLang}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['responseStatus'] == 200) {
          return data['responseData']['translatedText'] ?? text;
        }
      }
      
      // En cas d'erreur, retourne le texte original
      return text;
    } catch (e) {
      print('Translation error: $e');
      return text; // Retourne le texte original en cas d'erreur
    }
  }

  // Fonction pour obtenir la langue actuelle du système
  static String getCurrentLanguage() {
    // Par défaut, retourne le français
    // À intégrer avec SharedPreferences pour sauvegarder le choix utilisateur
    return 'fr';
  }

  // Fonction pour sauvegarder la langue choisie
  static Future<void> saveLanguage(String languageCode) async {
    // À implémenter avec SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('selected_language', languageCode);
  }
}
