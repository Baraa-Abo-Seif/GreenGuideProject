import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar'); // Default to Arabic
  final _storage = const FlutterSecureStorage();

  LocaleProvider() {
    _loadSavedLocale();
  }

  // Load saved locale from storage if it exists, otherwise use Arabic as default
  Future<void> _loadSavedLocale() async {
    String? savedLocale = await _storage.read(key: 'locale');
      if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
    notifyListeners();
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'ar'].contains(locale.languageCode)) return;
    _locale = locale;
    _storage.write(key: 'locale', value: locale.languageCode);
    notifyListeners();
  }
}
