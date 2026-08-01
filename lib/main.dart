import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/calculator_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  // Ensure Flutter engine bindings are fully initialized before asynchronous tasks
  WidgetsFlutterBinding.ensureInitialized();

  // Load local database engine (SharedPreferences)
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // Settings State Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs),
        ),
        
        // Calculator Operations State Provider
        ChangeNotifierProxyProvider<ThemeProvider, CalculatorProvider>(
          create: (_) => CalculatorProvider(prefs),
          update: (_, themeProvider, calcProvider) {
            if (calcProvider == null) {
              final newProvider = CalculatorProvider(prefs);
              newProvider.updateFormatSettings(
                themeProvider.decimalPrecision,
                themeProvider.thousandsSeparator,
              );
              return newProvider;
            }
            calcProvider.updateFormatSettings(
              themeProvider.decimalPrecision,
              themeProvider.thousandsSeparator,
            );
            return calcProvider;
          },
        ),
      ],
      child: const CalculatorApp(),
    ),
  );
}
