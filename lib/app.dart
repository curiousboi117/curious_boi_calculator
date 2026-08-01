import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'themes/dark_theme.dart';
import 'themes/light_theme.dart';
import 'utils/constants.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Premium Calculator',
      debugShowCheckedModeBanner: false,
      
      // Themes Setup
      themeMode: themeProvider.themeMode,
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      
      // Theme switching animation configurations
      home: AnimatedTheme(
        data: ThemeData(), // Empty placeholder, actual themes resolved inside home_screen
        duration: AppConstants.themeSwitchDuration,
        child: const HomeScreen(),
      ),
    );
  }
}
class AnimatedTheme extends StatelessWidget {
  final ThemeData data;
  final Duration duration;
  final Widget child;

  const AnimatedTheme({
    Key? key,
    required this.data,
    required this.duration,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeTheme = Theme.of(context);
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return Theme(
          data: activeTheme,
          child: child!,
        );
      },
      child: child,
    );
  }
}
