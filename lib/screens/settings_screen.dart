import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final calcProvider = Provider.of<CalculatorProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Section 1: Appearance
          _buildSectionHeader(context, 'Appearance'),
          
          // Theme selection using SegmentedButton (Material 3 standard)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.settings_system_daydream),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeProvider.themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      themeProvider.triggerFeedback();
                      themeProvider.setThemeMode(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          SwitchListTile(
            title: const Text('Dynamic Colors (Material You)'),
            subtitle: const Text('Adapt calculator colors to your device (Android only)'),
            value: themeProvider.dynamicColorEnabled,
            secondary: const Icon(Icons.color_lens_outlined),
            onChanged: (bool val) {
              themeProvider.triggerFeedback();
              themeProvider.setDynamicColorEnabled(val);
            },
          ),
          
          SwitchListTile(
            title: const Text('Glassmorphism Effect'),
            subtitle: const Text('Display frosted glass visual styling'),
            value: themeProvider.glassmorphicEnabled,
            secondary: const Icon(Icons.blur_on_outlined),
            onChanged: (bool val) {
              themeProvider.triggerFeedback();
              themeProvider.setGlassmorphicEnabled(val);
            },
          ),
          
          const Divider(),

          // Section 2: Behavior
          _buildSectionHeader(context, 'Behavior'),
          
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate device on keypress'),
            value: themeProvider.hapticEnabled,
            secondary: const Icon(Icons.vibration_outlined),
            onChanged: (bool val) {
              themeProvider.triggerFeedback();
              themeProvider.setHapticEnabled(val);
            },
          ),

          SwitchListTile(
            title: const Text('Key Sounds'),
            subtitle: const Text('Play system audio on keypress'),
            value: themeProvider.soundEnabled,
            secondary: const Icon(Icons.volume_up_outlined),
            onChanged: (bool val) {
              themeProvider.triggerFeedback();
              themeProvider.setSoundEnabled(val);
            },
          ),

          const Divider(),

          // Section 3: Formatting
          _buildSectionHeader(context, 'Formatting'),

          SwitchListTile(
            title: const Text('Thousands Separator'),
            subtitle: const Text('Format numbers with commas (e.g., 1,000,000)'),
            value: themeProvider.thousandsSeparator,
            secondary: const Icon(Icons.grid_3x3_outlined),
            onChanged: (bool val) {
              themeProvider.triggerFeedback();
              themeProvider.setThousandsSeparator(val);
              calcProvider.updateFormatSettings(
                themeProvider.decimalPrecision,
                val,
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          'Decimal Precision',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Text(
                      '${themeProvider.decimalPrecision} places',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Slider(
                  value: themeProvider.decimalPrecision.toDouble(),
                  min: 0.0,
                  max: 15.0,
                  divisions: 15,
                  label: '${themeProvider.decimalPrecision}',
                  onChanged: (double val) {
                    themeProvider.setDecimalPrecision(val.toInt());
                    calcProvider.updateFormatSettings(
                      val.toInt(),
                      themeProvider.thousandsSeparator,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Divider(),

          // Section 4: About
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Curious Boi Calculator'),
            subtitle: const Text('V1.0.0 (Material 3)'),
            trailing: const Text('by Curious Boi'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
