import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tranoo/utils/locale_helper.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale';

  Locale? _locale;
  Locale? get locale => _locale;

  String get languageCode => _locale?.languageCode ?? 'fr';

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null &&
          code.isNotEmpty &&
          LocaleHelper.supportedLanguageCodes.contains(code)) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!LocaleHelper.supportedLanguageCodes.contains(locale.languageCode)) {
      return;
    }
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locale.languageCode);
    } catch (_) {
      // ignore
    }
  }
}
