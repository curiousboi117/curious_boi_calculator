import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';

class CalculatorDisplay extends StatefulWidget {
  const CalculatorDisplay({Key? key}) : super(key: key);

  @override
  State<CalculatorDisplay> createState() => _CalculatorDisplayState();
}

class _CalculatorDisplayState extends State<CalculatorDisplay> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calcProvider = Provider.of<CalculatorProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    

    // Trigger auto scroll to end when expression changes
    _scrollToEnd();

    return Container(
      
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 8 : 16,
      ),
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Current Expression Scroll View
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            reverse: true, // starts from right-aligned position
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  calcProvider.expression.isEmpty ? '0' : calcProvider.expression,
                  style: TextStyle(
                    fontSize: isSmallScreen
                        ? (calcProvider.result.isNotEmpty ? 22 : 32)
                        : (calcProvider.result.isNotEmpty ? 28 : 40),
                    fontWeight: FontWeight.w300,
                    color: isDark ? const Color(0xFFE6E1E5) : const Color(0xFF1C1B1F),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Live Preview (visible when user is typing and result is empty)
          if (calcProvider.previewResult.isNotEmpty && calcProvider.result.isEmpty)
            AnimatedOpacity(
              opacity: calcProvider.previewResult.isNotEmpty ? 0.7 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Text(
                calcProvider.previewResult,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.outline,
                ),
              ),
            ),

          // Final Result Display
          if (calcProvider.result.isNotEmpty)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  alignment: Alignment.centerRight,
                  child: child,
                );
              },
              child: SelectableText(
                calcProvider.result,
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? (calcProvider.result == 'Error' || calcProvider.result == 'Math Error'
                          ? 28
                          : 38)
                      : (calcProvider.result == 'Error' || calcProvider.result == 'Math Error'
                          ? 36
                          : 48),
                  fontWeight: FontWeight.bold,
                  color: calcProvider.result == 'Error' || calcProvider.result == 'Math Error'
                      ? theme.colorScheme.error
                      : (themeProvider.dynamicColorEnabled
                          ? theme.colorScheme.primary
                          : (isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4))),
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }
}
