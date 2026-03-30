import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(loc != null, 'AppLocalizations not found in context');
    return loc!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<void> load() async {
    final code = locale.languageCode.toLowerCase();
    final path = 'assets/i18n/$code.json';
    final jsonStr = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonMap =
        (json.decode(jsonStr) as Map).cast<String, dynamic>();
    _strings = jsonMap.map((k, v) => MapEntry(k, v.toString()));
  }

  String tr(String key, {Map<String, String> params = const {}}) {
    var out = _strings[key] ?? key;
    if (params.isEmpty) return out;
    params.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  static const _supported = ['en', 'ar'];

  @override
  bool isSupported(Locale locale) => _supported.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final l = AppLocalizations(locale);
    await l.load();
    return l;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppTr on String {
  String tr(BuildContext context, {Map<String, String> params = const {}}) {
    return AppLocalizations.of(context).tr(this, params: params);
  }
}
