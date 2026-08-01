class AppConstants {
  // Shared Preferences Keys
  static const String keyThemeMode = 'prefs_theme_mode';
  static const String keyHapticEnabled = 'prefs_haptic_enabled';
  static const String keySoundEnabled = 'prefs_sound_enabled';
  static const String keyDecimalPrecision = 'prefs_decimal_precision';
  static const String keyThousandsSeparator = 'prefs_thousands_separator';
  static const String keyGlassmorphismEnabled = 'prefs_glassmorphic_enabled';
  static const String keyDynamicColorEnabled = 'prefs_dynamic_color_enabled';
  static const String keyHistoryList = 'prefs_calculation_history';
  static const String keyMemoryValue = 'prefs_calculator_memory';

  // Layout limits and responsiveness breakpoints
  static const double mobileBreakPoint = 600.0;
  static const double desktopBreakPoint = 900.0;
  static const double maxContentWidth = 1200.0;

  // Visual layout constants
  static const double defaultPadding = 16.0;
  static const double buttonSpacing = 12.0;
  static const double buttonRadius = 28.0;
  static const double displayHeightRatio = 0.35; // 35% of height for screen

  // Animation Durations
  static const Duration themeSwitchDuration = Duration(milliseconds: 350);
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
  static const Duration panelSlideDuration = Duration(milliseconds: 300);
  static const Duration listAnimationDuration = Duration(milliseconds: 250);

  // Default values
  static const int defaultPrecision = 8;
  static const bool defaultHapticEnabled = true;
  static const bool defaultSoundEnabled = false;
  static const bool defaultThousandsSeparator = true;
  static const bool defaultGlassmorphism = false;
  static const bool defaultDynamicColors = false;
}
