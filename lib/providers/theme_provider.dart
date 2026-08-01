import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  bool _hapticEnabled = AppConstants.defaultHapticEnabled;
  bool _soundEnabled = AppConstants.defaultSoundEnabled;
  int _decimalPrecision = AppConstants.defaultPrecision;
  bool _thousandsSeparator = AppConstants.defaultThousandsSeparator;
  bool _glassmorphicEnabled = AppConstants.defaultGlassmorphism;
  bool _dynamicColorEnabled = AppConstants.defaultDynamicColors;

  ThemeProvider(this._prefs) {
    _loadSettings();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get hapticEnabled => _hapticEnabled;
  bool get soundEnabled => _soundEnabled;
  int get decimalPrecision => _decimalPrecision;
  bool get thousandsSeparator => _thousandsSeparator;
  bool get glassmorphicEnabled => _glassmorphicEnabled;
  bool get dynamicColorEnabled => _dynamicColorEnabled;

  void _loadSettings() {
    // Theme Mode
    final themeStr = _prefs.getString(AppConstants.keyThemeMode);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ThemeMode.system,
      );
    }

    // Toggles
    _hapticEnabled = _prefs.getBool(AppConstants.keyHapticEnabled) ?? AppConstants.defaultHapticEnabled;
    _soundEnabled = _prefs.getBool(AppConstants.keySoundEnabled) ?? AppConstants.defaultSoundEnabled;
    _thousandsSeparator = _prefs.getBool(AppConstants.keyThousandsSeparator) ?? AppConstants.defaultThousandsSeparator;
    _glassmorphicEnabled = _prefs.getBool(AppConstants.keyGlassmorphismEnabled) ?? AppConstants.defaultGlassmorphism;
    _dynamicColorEnabled = _prefs.getBool(AppConstants.keyDynamicColorEnabled) ?? AppConstants.defaultDynamicColors;

    // Precision
    _decimalPrecision = _prefs.getInt(AppConstants.keyDecimalPrecision) ?? AppConstants.defaultPrecision;
    notifyListeners();
  }

  // Setters with persistent storage and notification
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(AppConstants.keyThemeMode, mode.toString());
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    await _prefs.setBool(AppConstants.keyHapticEnabled, enabled);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _prefs.setBool(AppConstants.keySoundEnabled, enabled);
    notifyListeners();
  }

  Future<void> setDecimalPrecision(int precision) async {
    _decimalPrecision = precision.clamp(0, 15);
    await _prefs.setInt(AppConstants.keyDecimalPrecision, _decimalPrecision);
    notifyListeners();
  }

  Future<void> setThousandsSeparator(bool enabled) async {
    _thousandsSeparator = enabled;
    await _prefs.setBool(AppConstants.keyThousandsSeparator, enabled);
    notifyListeners();
  }

  Future<void> setGlassmorphicEnabled(bool enabled) async {
    _glassmorphicEnabled = enabled;
    await _prefs.setBool(AppConstants.keyGlassmorphismEnabled, enabled);
    notifyListeners();
  }

  Future<void> setDynamicColorEnabled(bool enabled) async {
    _dynamicColorEnabled = enabled;
    await _prefs.setBool(AppConstants.keyDynamicColorEnabled, enabled);
    notifyListeners();
  }

  // Utility to trigger haptics and sounds based on settings
  void triggerFeedback() {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
