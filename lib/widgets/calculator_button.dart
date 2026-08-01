import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

enum ButtonType {
  number,
  operator,
  function,
  scientific,
  equal,
}

class CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final ButtonType type;
  final double aspectRatio;

  const CalculatorButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.type = ButtonType.number,
    this.aspectRatio = 1.0,
  }) : super(key: key);

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve colors based on theme settings & button type
    Color bg;
    Color fg;

    switch (widget.type) {
      case ButtonType.number:
        bg = isDark ? AppColors.numberBtnDark : AppColors.numberBtnLight;
        fg = isDark ? AppColors.onNumberBtnDark : AppColors.onNumberBtnLight;
        break;
      case ButtonType.operator:
        bg = isDark ? AppColors.operatorBtnDark : AppColors.operatorBtnLight;
        fg = isDark ? AppColors.onOperatorBtnDark : AppColors.onOperatorBtnLight;
        break;
      case ButtonType.function:
        bg = isDark ? AppColors.functionBtnDark : AppColors.functionBtnLight;
        fg = isDark ? AppColors.onFunctionBtnDark : AppColors.onFunctionBtnLight;
        break;
      case ButtonType.scientific:
        bg = isDark ? AppColors.scientificBtnDark : AppColors.scientificBtnLight;
        fg = isDark ? AppColors.onScientificBtnDark : AppColors.onScientificBtnLight;
        break;
      case ButtonType.equal:
        bg = isDark ? AppColors.equalBtnDark : AppColors.equalBtnLight;
        fg = isDark ? AppColors.onEqualBtnDark : AppColors.onEqualBtnLight;
        break;
    }

    // Dynamic Material You overrides
    if (themeProvider.dynamicColorEnabled) {
      switch (widget.type) {
        case ButtonType.operator:
          bg = theme.colorScheme.secondaryContainer;
          fg = theme.colorScheme.onSecondaryContainer;
          break;
        case ButtonType.equal:
          bg = theme.colorScheme.primary;
          fg = theme.colorScheme.onPrimary;
          break;
        default:
          break;
      }
    }

    // Apply scale animation factor
    final scale = _isPressed ? 0.92 : (_isHovered ? 1.03 : 1.0);

    Widget buttonContent = Center(
      child: Text(
        widget.text,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width < 400
              ? (widget.type == ButtonType.scientific ? 14 : 20)
              : (widget.type == ButtonType.scientific ? 18 : 26),
          fontWeight: widget.type == ButtonType.equal || widget.type == ButtonType.operator
              ? FontWeight.bold
              : FontWeight.w500,
          color: fg,
        ),
      ),
    );

    // Apply glassmorphism overlay if enabled
    Widget containerChild;
    if (themeProvider.glassmorphicEnabled) {
      final glassBg = isDark ? AppColors.glassBgDark : AppColors.glassBgLight;
      final glassBorder = isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight;

      containerChild = ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: AppConstants.buttonPressDuration,
            decoration: BoxDecoration(
              color: _isPressed ? glassBg.withOpacity(isDark ? 0.4 : 0.6) : glassBg,
              borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
              border: Border.all(color: glassBorder, width: 1.5),
            ),
            child: buttonContent,
          ),
        ),
      );
    } else {
      containerChild = AnimatedContainer(
        duration: AppConstants.buttonPressDuration,
        decoration: BoxDecoration(
          color: _isPressed
              ? bg.withOpacity(0.7)
              : (_isHovered ? bg.withOpacity(0.9) : bg),
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: buttonContent,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          themeProvider.triggerFeedback();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: scale,
          duration: AppConstants.buttonPressDuration,
          curve: Curves.easeOutBack,
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: containerChild,
          ),
        ),
      ),
    );
  }
}
