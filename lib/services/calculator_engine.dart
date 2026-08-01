import '../utils/constants.dart';
import 'expression_parser.dart';

class CalculatorEngine {
  // Append characters to the expression, enforcing input constraints
  static String append(String current, String input) {
    if (current.isEmpty) {
      // Don't start with binary operators (except unary plus/minus/functions)
      if (['+', '×', '÷', '*', '/', '^', '%', '!', ')'].contains(input)) {
        return current;
      }
      return input;
    }

    final lastChar = current.substring(current.length - 1);

    // Prevent multiple decimals in the same number
    if (input == '.') {
      // Find the last number sequence
      final numberReg = RegExp(r'[0-9.]+$');
      final match = numberReg.firstMatch(current);
      if (match != null && match.group(0)!.contains('.')) {
        return current; // Already has a decimal point in the current number
      }
      if (!RegExp(r'[0-9]').hasMatch(lastChar)) {
        // If last character is not a digit (e.g. +, *, ( ), insert 0.
        return '$current' '0.';
      }
    }

    // Prevent consecutive binary operators. If an operator is input, and the last char is an operator, replace it!
    final isNewOp = ['+', '−', '×', '÷', '*', '/', '^'].contains(input);
    final isLastOp = ['+', '−', '×', '÷', '*', '/', '^'].contains(lastChar);
    if (isNewOp && isLastOp) {
      return current.substring(0, current.length - 1) + input;
    }

    // Suffix operator % or ! can only follow a digit, constant, or right parenthesis
    if (input == '%' || input == '!') {
      if (!RegExp(r'[0-9πe)]').hasMatch(lastChar)) {
        return current; // invalid position
      }
    }

    // Prevent starting a number directly after a constant or right parenthesis without operator
    if (RegExp(r'[0-9]').hasMatch(input)) {
      if (lastChar == 'π' || lastChar == 'e' || lastChar == ')') {
        return '$current' '×$input'; // Implicit multiplication
      }
    }

    // Implicit multiplication when opening parenthesis or function after number or constant
    if (input == '(' || input.endsWith('(')) {
      if (RegExp(r'[0-9πe)]').hasMatch(lastChar)) {
        return '$current' '×$input';
      }
    }

    return current + input;
  }

  // Deletes the last token or character (backspace)
  static String backspace(String current) {
    if (current.isEmpty) return current;

    // Check for multi-character functions at the end
    final functions = [
      'asin(', 'acos(', 'atan(',
      'sin(', 'cos(', 'tan(',
      'log(', 'ln(', 'sqrt(', 'cbrt(', 'abs('
    ];

    for (final func in functions) {
      if (current.endsWith(func)) {
        return current.substring(0, current.length - func.length);
      }
    }

    // Check for special character segments
    if (current.endsWith('(-')) {
      return current.substring(0, current.length - 2);
    }

    // Default: delete 1 character
    return current.substring(0, current.length - 1);
  }

  // Toggles the sign of the trailing number sequence
  static String toggleSign(String expression) {
    if (expression.isEmpty) return '-';
    if (expression == '-') return '';

    if (expression.endsWith('(-')) {
      return expression.substring(0, expression.length - 2);
    }

    // Match (-123.45) at the end of the expression
    final wrappedReg = RegExp(r'\(\-([0-9.πe]+)\)$');
    final wrappedMatch = wrappedReg.firstMatch(expression);
    if (wrappedMatch != null) {
      final value = wrappedMatch.group(1)!;
      final prefix = expression.substring(0, expression.length - wrappedMatch.group(0)!.length);
      return prefix + value;
    }

    // Match standard trailing number or constant
    final numReg = RegExp(r'([0-9.πe]+)$');
    final numMatch = numReg.firstMatch(expression);
    if (numMatch != null) {
      final numStr = numMatch.group(1)!;
      final prefix = expression.substring(0, expression.length - numStr.length);
      return '$prefix(-$numStr)';
    }

    // If it ends with an operator, open parenthesis, append `(-`
    final lastChar = expression.substring(expression.length - 1);
    if (['+', '−', '×', '÷', '*', '/', '^', '('].contains(lastChar)) {
      return '$expression(-';
    }

    return '$expression-';
  }

  // Evaluates the math expression and returns the double result
  static double evaluate(String expression) {
    // Replace custom display operators with standard ones
    String parsedExpr = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
        
    // Standardize implicit multiplication for constants (e.g. 5pi -> 5*pi)
    parsedExpr = parsedExpr.replaceAllMapped(RegExp(r'(\d)(π|e)'), (match) => '${match[1]}*${match[2]}');
    parsedExpr = parsedExpr.replaceAllMapped(RegExp(r'(π|e)(\d)'), (match) => '${match[1]}*${match[2]}');
    parsedExpr = parsedExpr.replaceAllMapped(RegExp(r'(π|e)(π|e)'), (match) => '${match[1]}*${match[2]}');

    return ExpressionParser.evaluate(parsedExpr);
  }

  // Format double output into a readable string
  static String formatResult(
    double value, {
    int precision = AppConstants.defaultPrecision,
    bool useSeparator = AppConstants.defaultThousandsSeparator,
  }) {
    if (value.isNaN) return "Math Error";
    if (value.isInfinite) return value.isNegative ? "-Infinity" : "Infinity";

    // Format scientific notation for extremely large/small numbers
    final absVal = value.abs();
    if (absVal > 1e14 || (absVal < 1e-7 && absVal > 0)) {
      return value.toStringAsExponential(4);
    }

    // Round to specified precision
    String formatted = value.toStringAsFixed(precision);

    // Remove trailing decimal zeros
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }

    // Inject thousands separators
    if (useSeparator && !formatted.contains('e')) {
      final parts = formatted.split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? '.' + parts[1] : '';

      final isNegative = integerPart.startsWith('-');
      final cleanInt = isNegative ? integerPart.substring(1) : integerPart;

      final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      final formattedInt = cleanInt.replaceAllMapped(reg, (Match m) => '${m[1]},');

      formatted = (isNegative ? '-' : '') + formattedInt + decimalPart;
    }

    return formatted;
  }
}
