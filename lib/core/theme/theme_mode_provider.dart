import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

FlutterSecureStorage _createStorage() {
  return kIsWeb
      ? const FlutterSecureStorage()
      : const FlutterSecureStorage();
}

ThemeMode _modeFromString(String? v) {
  switch ((v ?? '').toLowerCase()) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String _modeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
    default:
      return 'system';
  }
}

final initialThemeModeProvider = Provider<ThemeMode>((_) => ThemeMode.system);

Future<ThemeMode?> loadSavedThemeMode() async {
  final storage = _createStorage();
  final v = await storage.read(key: StorageKeys.themeMode);
  if (v == null || v.isEmpty) return null;
  return _modeFromString(v);
}

Future<ThemeMode> loadStartupThemeMode() async {
  final saved = await loadSavedThemeMode();
  return saved ?? ThemeMode.system;
}

class ThemeModeController extends StateNotifier<ThemeMode> {
  final Ref _ref;
  final FlutterSecureStorage _storage;

  ThemeModeController(this._ref)
      : _storage = _createStorage(),
        super(_ref.read(initialThemeModeProvider));

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await _storage.write(key: StorageKeys.themeMode, value: _modeToString(mode));
  }

  Future<void> setThemeModeString(String v) async {
    await setThemeMode(_modeFromString(v));
  }

  Future<void> useSystemTheme() async {
    await _storage.delete(key: StorageKeys.themeMode);
    if (state != ThemeMode.system) state = ThemeMode.system;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(ref),
);
