// lib/presentation/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_preferences_provider.dart';

const _kThemeModeKey = 'themeMode'; // 'light' | 'dark' | 'system'

final themeModeProvider =
StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final raw = prefs.getString(_kThemeModeKey);

    switch (raw) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.system;
        break;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_kThemeModeKey, str);
  }

  Future<void> toggleLightDark() async {
    // Only toggles between Light <-> Dark. System stays as-is unless explicitly set.
    final next = (state == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}
