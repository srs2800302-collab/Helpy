import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _strings;

  const AppLocalizations._(this.locale, this._strings);

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'AppLocalizations not found in context');
    return result!;
  }

  String t(String key) => _strings[key] ?? key;

  static Future<AppLocalizations> load(Locale locale) async {
    final code = locale.languageCode;
    final raw = await rootBundle.loadString('assets/translations/$code.json');
    final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
    final mapped = decoded.map((key, value) => MapEntry(key, value.toString()));
    return AppLocalizations._(locale, mapped);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en', 'th'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
