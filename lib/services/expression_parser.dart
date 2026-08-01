import 'dart:math' as math;

enum TokenType {
  number,
  constant,
  operator,
  function,
  leftParenthesis,
  rightParenthesis,
}

class Token {
  final TokenType type;
  final String value;
  Token(this.type, this.value);

  @override
  String toString() => 'Token(${type.name}, "$value")';
}

class ExpressionParser {
  // Normalize the input string before tokenization
  static String normalizeExpression(String expr) {
    return expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-') // Replace en-dash or similar with standard hyphen
        .replaceAll(' ', '');
  }

  // Check if string is a number
  static bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57; // '0' to '9'
  }

  // Tokenize the math expression
  static List<Token> tokenize(String expr) {
    final normalized = normalizeExpression(expr);
    final List<Token> tokens = [];
    int i = 0;

    while (i < normalized.length) {
      final char = normalized[i];

      if (char == ' ') {
        i++;
        continue;
      }

      // Check for numbers (including decimals)
      if (_isDigit(char) || char == '.') {
        final buffer = StringBuffer();
        bool hasDecimal = false;
        while (i < normalized.length && (_isDigit(normalized[i]) || normalized[i] == '.')) {
          if (normalized[i] == '.') {
            if (hasDecimal) throw const FormatException("Invalid number: multiple decimals");
            hasDecimal = true;
          }
          buffer.write(normalized[i]);
          i++;
        }
        tokens.add(Token(TokenType.number, buffer.toString()));
        continue;
      }

      // Check for constants and functions (alphabetical characters)
      if (RegExp(r'[a-zA-Zπ]').hasMatch(char)) {
        final buffer = StringBuffer();
        // Constant pi can be the symbol π
        if (char == 'π') {
          tokens.add(Token(TokenType.constant, 'π'));
          i++;
          continue;
        }

        while (i < normalized.length && RegExp(r'[a-zA-Z0-9]').hasMatch(normalized[i])) {
          buffer.write(normalized[i]);
          i++;
        }
        final word = buffer.toString();

        if (word == 'e') {
          tokens.add(Token(TokenType.constant, 'e'));
        } else if (word == 'pi') {
          tokens.add(Token(TokenType.constant, 'π'));
        } else if ([
          'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
          'log', 'ln', 'sqrt', 'cbrt', 'abs'
        ].contains(word)) {
          tokens.add(Token(TokenType.function, word));
        } else {
          throw FormatException("Unknown symbol/function: $word");
        }
        continue;
      }

      // Check for operators and parentheses
      if (char == '(') {
        tokens.add(Token(TokenType.leftParenthesis, '('));
        i++;
      } else if (char == ')') {
        tokens.add(Token(TokenType.rightParenthesis, ')'));
        i++;
      } else if (['+', '-', '*', '/', '^', '%', '!'].contains(char)) {
        // Detect unary minus
        if (char == '-' || char == '+') {
          bool isUnary = false;
          if (tokens.isEmpty) {
            isUnary = true;
          } else {
            final prev = tokens.last;
            if (prev.type == TokenType.operator && prev.value != '%' && prev.value != '!') {
              isUnary = true;
            } else if (prev.type == TokenType.leftParenthesis) {
              isUnary = true;
            }
          }
          if (isUnary) {
            tokens.add(Token(TokenType.operator, char == '-' ? 'u-' : 'u+'));
            i++;
            continue;
          }
        }
        tokens.add(Token(TokenType.operator, char));
        i++;
      } else {
        throw FormatException("Invalid character in expression: $char");
      }
    }

    return tokens;
  }

  // Get operator precedence
  static int _getPrecedence(String op) {
    switch (op) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
        return 2;
      case '^':
        return 3;
      case 'u-':
      case 'u+':
        return 4;
      case '%':
      case '!':
        return 5;
      default:
        return 0;
    }
  }

  // Check if operator is right-associative
  static bool _isRightAssociative(String op) {
    return op == '^' || op == 'u-' || op == 'u+';
  }

  // Convert infix tokens to postfix (Reverse Polish Notation) using Shunting-Yard
  static List<Token> shuntingYard(List<Token> tokens) {
    final List<Token> outputQueue = [];
    final List<Token> operatorStack = [];

    for (final token in tokens) {
      switch (token.type) {
        case TokenType.number:
        case TokenType.constant:
          outputQueue.add(token);
          break;
        case TokenType.function:
          operatorStack.add(token);
          break;
        case TokenType.operator:
          final o1 = token.value;
          while (operatorStack.isNotEmpty) {
            final top = operatorStack.last;
            if (top.type == TokenType.leftParenthesis) break;

            if (top.type == TokenType.function) {
              outputQueue.add(operatorStack.removeLast());
              continue;
            }

            final o2 = top.value;
            final p1 = _getPrecedence(o1);
            final p2 = _getPrecedence(o2);

            if (p2 > p1 || (p2 == p1 && !_isRightAssociative(o1))) {
              outputQueue.add(operatorStack.removeLast());
            } else {
              break;
            }
          }
          operatorStack.add(token);
          break;
        case TokenType.leftParenthesis:
          operatorStack.add(token);
          break;
        case TokenType.rightParenthesis:
          bool foundLeft = false;
          while (operatorStack.isNotEmpty) {
            final top = operatorStack.last;
            if (top.type == TokenType.leftParenthesis) {
              foundLeft = true;
              operatorStack.removeLast(); // Remove '('
              break;
            } else {
              outputQueue.add(operatorStack.removeLast());
            }
          }
          if (!foundLeft) {
            throw const FormatException("Mismatched parentheses (missing left parenthesis)");
          }
          // If the top of the stack is a function, pop it onto the output queue
          if (operatorStack.isNotEmpty && operatorStack.last.type == TokenType.function) {
            outputQueue.add(operatorStack.removeLast());
          }
          break;
      }
    }

    while (operatorStack.isNotEmpty) {
      final top = operatorStack.last;
      if (top.type == TokenType.leftParenthesis || top.type == TokenType.rightParenthesis) {
        throw const FormatException("Mismatched parentheses");
      }
      outputQueue.add(operatorStack.removeLast());
    }

    return outputQueue;
  }

  // Helper to compute factorial
  static double _factorial(double x) {
    if (x < 0) throw const FormatException("Factorial of negative number is undefined");
    if (x % 1 != 0) {
      throw const FormatException("Factorial of non-integer is undefined");
    }
    final n = x.toInt();
    if (n > 170) throw const FormatException("Factorial overflow (max input is 170)");
    double result = 1.0;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  // Evaluate postfix (RPN) expression
  static double evaluate(String expr) {
    final tokens = tokenize(expr);
    if (tokens.isEmpty) return 0.0;
    final rpn = shuntingYard(tokens);

    final List<double> stack = [];

    for (final token in rpn) {
      if (token.type == TokenType.number) {
        stack.add(double.parse(token.value));
      } else if (token.type == TokenType.constant) {
        if (token.value == 'π') {
          stack.add(math.pi);
        } else if (token.value == 'e') {
          stack.add(math.e);
        }
      } else if (token.type == TokenType.function) {
        if (stack.isEmpty) throw const FormatException("Missing operand for function");
        final x = stack.removeLast();
        double res = 0.0;
        switch (token.value) {
          case 'sin':
            res = math.sin(x);
            break;
          case 'cos':
            res = math.cos(x);
            break;
          case 'tan':
            // Check for tan vertical asymptotes e.g. tan(pi/2)
            if ((x - math.pi / 2).abs() % math.pi < 1e-9) {
              throw const FormatException("Math Error: tan asymptote");
            }
            res = math.tan(x);
            break;
          case 'asin':
            if (x < -1 || x > 1) throw const FormatException("Math Error: arcsin domain is [-1, 1]");
            res = math.asin(x);
            break;
          case 'acos':
            if (x < -1 || x > 1) throw const FormatException("Math Error: arccos domain is [-1, 1]");
            res = math.acos(x);
            break;
          case 'atan':
            res = math.atan(x);
            break;
          case 'log':
            if (x <= 0) throw const FormatException("Math Error: log domain must be > 0");
            res = math.log(x) / math.ln10;
            break;
          case 'ln':
            if (x <= 0) throw const FormatException("Math Error: ln domain must be > 0");
            res = math.log(x);
            break;
          case 'sqrt':
            if (x < 0) throw const FormatException("Math Error: square root of negative number");
            res = math.sqrt(x);
            break;
          case 'cbrt':
            // Cube root is defined for negative numbers too
            res = x < 0
    		? -math.pow(-x, 1 / 3).toDouble()
   		: math.pow(x, 1 / 3).toDouble();
            break;
          case 'abs':
            res = x.abs();
            break;
          default:
            throw FormatException("Unknown function: ${token.value}");
        }
        stack.add(res);
      } else if (token.type == TokenType.operator) {
        final op = token.value;
        // Unary prefix operators
        if (op == 'u-' || op == 'u+') {
          if (stack.isEmpty) throw const FormatException("Missing operand for unary operator");
          final x = stack.removeLast();
          stack.add(op == 'u-' ? -x : x);
          continue;
        }

        // Unary postfix operators
        if (op == '%' || op == '!') {
          if (stack.isEmpty) throw const FormatException("Missing operand for postfix operator");
          final x = stack.removeLast();
          if (op == '%') {
            stack.add(x / 100);
          } else {
            stack.add(_factorial(x));
          }
          continue;
        }

        // Binary operators
        if (stack.length < 2) throw const FormatException("Missing operand for binary operator");
        final b = stack.removeLast();
        final a = stack.removeLast();
        double res = 0.0;
        switch (op) {
          case '+':
            res = a + b;
            break;
          case '-':
            res = a - b;
            break;
          case '*':
            res = a * b;
            break;
          case '/':
            if (b == 0) throw const FormatException("Cannot divide by zero");
            res = a / b;
            break;
          case '^':
            // Check edge case: 0^0 or negative base with fractional exponent
            if (a == 0 && b == 0) {
              // 0^0 is controversial, usually undefined or 1. Let's make it 1 or throw. Standard is 1.
              res = 1.0;
            } else if (a < 0 && b % 1 != 0) {
              throw const FormatException("Math Error: negative base with fractional power");
            } else {
              res = math.pow(a, b).toDouble();
            }
            break;
          default:
            throw FormatException("Unknown operator: $op");
        }
        stack.add(res);
      }
    }

    if (stack.length != 1) {
      throw const FormatException("Invalid expression (unresolved operators or numbers)");
    }

    return stack.single;
  }
}
