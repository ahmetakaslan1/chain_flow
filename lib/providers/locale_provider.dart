import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class LocaleProvider with ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');
  static const String _key = 'appLocale';

  LocaleProvider() {
    final saved = _settingsBox.get(_key) as String?;
    if (saved != null) {
      _locale = Locale(saved);
      Intl.defaultLocale = saved == 'en' ? 'en_US' : 'tr_TR';
    } else {
      Intl.defaultLocale = 'tr_TR';
    }
  }

  Locale _locale = const Locale('tr');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    _settingsBox.put(_key, locale.languageCode);
    Intl.defaultLocale = locale.languageCode == 'en' ? 'en_US' : 'tr_TR';
    notifyListeners();
  }
}
