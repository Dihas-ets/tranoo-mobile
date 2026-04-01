import 'package:flutter/material.dart';
import 'package:tranoo/services/translation_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'fr'; // Langue par défaut
  
  String get currentLanguage => _currentLanguage;
  
  Map<String, String> get supportedLanguages => TranslationService.supportedLanguages;

  void changeLanguage(String languageCode) {
    if (_currentLanguage != languageCode && supportedLanguages.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      TranslationService.saveLanguage(languageCode);
      notifyListeners();
    }
  }

  String getCurrentLanguageName() {
    return supportedLanguages[_currentLanguage] ?? 'Français';
  }

  // Fonction de traduction simplifiée
  Future<String> translate(String text, {String? from}) async {
    if (_currentLanguage == 'fr' || from == _currentLanguage) {
      return text; // Pas besoin de traduire
    }
    
    return await TranslationService.translate(
      text, 
      from ?? 'fr', 
      _currentLanguage
    );
  }
}
