import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared_preferences_provider.dart';

const _kLocaleKey = 'localeCode';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier(ref));

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref _ref;

  LocaleNotifier(this._ref) : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final code = prefs.getString(_kLocaleKey);
    if (code != null && code.isNotEmpty) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}
