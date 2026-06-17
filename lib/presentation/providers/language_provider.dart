// lib/presentation/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LanguageProvider with ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _key = 'app_language';

  Locale _locale = const Locale('fr');
  Locale get locale => _locale;

  String get currentLanguageCode => _locale.languageCode;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'wo', 'name': 'Wolof', 'flag': '🇸🇳'},
  ];

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final saved = await _storage.read(key: _key);
    if (saved != null) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await _storage.write(key: _key, value: languageCode);
    notifyListeners();
  }

  String get languageName {
    return supportedLanguages
        .firstWhere((l) => l['code'] == currentLanguageCode,
            orElse: () => supportedLanguages.first)['name']!;
  }
}
