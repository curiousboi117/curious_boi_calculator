import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/display.dart';
import '../widgets/keyboard.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Handle physical keyboard inputs
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.backspace) {
      provider.triggerFeedback();
      provider.backspace();
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      provider.triggerFeedback();
      provider.evaluate();
    } else if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.delete) {
      provider.triggerFeedback();
      provider.clear();
    } else {
      // Use character string representation to handle Shift states (e.g., '*' instead of '8' with shift)
      final char = event.character;
      if (char != null && RegExp(r'[0-9.+\-*/%()]').hasMatch(char)) {
        provider.triggerFeedback();
        String mapChar = char;
        if (char == '*') mapChar = '×';
        if (char == '/') mapChar = '÷';
        if (char == '-') mapChar = '−';
        provider.append(mapChar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calcProvider = Provider.of<CalculatorProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Request keyboard focus
    FocusScope.of(context).requestFocus(_focusNode);

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Calculator',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            // Scientific Mode Toggle
            IconButton(
              icon: Icon(
                calcProvider.isScientific
                    ? Icons.science
                    : Icons.science_outlined,
                color: calcProvider.isScientific ? theme.colorScheme.primary : null,
              ),
              tooltip: 'Scientific Mode',
              onPressed: () {
                themeProvider.triggerFeedback();
                calcProvider.toggleScientific();
              },
            ),
            // Standalone history trigger (only visible on mobile layout)
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = MediaQuery.of(context).size.width;
                if (width < AppConstants.desktopBreakPoint) {
                  return IconButton(
                    icon: const Icon(Icons.history_outlined),
                    tooltip: 'History',
                    onPressed: () {
                      themeProvider.triggerFeedback();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Settings Screen Trigger
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () {
                themeProvider.triggerFeedback();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(width: 8.0),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              
              // Desktop layout: Split view with embedded History list next to calculator
              if (width >= AppConstants.desktopBreakPoint) {
                return Row(
                  children: [
                    // Left Side: Calculator Core (Display & Keyboard)
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: theme.dividerColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Expanded(
                              flex: 3,
                              child: CalculatorDisplay(),
                            ),
                            const Divider(height: 1.0, thickness: 1.0),
                            Expanded(
                              flex: 7,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 600),
                                    child: const CalculatorKeyboard(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Right Side: Pinned History sidebar
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: isDark ? const Color(0xFF141416) : const Color(0xFFF6F6F9),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'History Sidebar',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      themeProvider.triggerFeedback();
                                      calcProvider.clearHistory();
                                    },
                                    icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              const Expanded(
                                child: HistoryListWidget(embedMode: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Tablet landscape layout (medium screens: layout side-by-side but no history sidebar)
              if (width >= AppConstants.mobileBreakPoint) {
                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: CalculatorDisplay(),
                        ),
                        Divider(height: 1.0, thickness: 1.0),
                        Expanded(
                          flex: 7,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: CalculatorKeyboard(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Standard Mobile Layout (Portrait)
              return Column(
                children: const [
                  Expanded(
                    flex: 3,
                    child: CalculatorDisplay(),
                  ),
                  Divider(height: 1.0, thickness: 1.0),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 16.0),
                      child: CalculatorKeyboard(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Extension helper to set constraints directly in widgets list (tablet container limits)
extension on Widget {
  Widget maxConstraints({required BoxConstraints maxConstraints}) {
    return ConstrainedBox(
      constraints: maxConstraints,
      child: this,
    );
  }
}
