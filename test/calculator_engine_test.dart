import 'package:flutter_test/flutter_test.dart';
import '../lib/services/calculator_engine.dart';
import '../lib/services/expression_parser.dart';

void main() {
  group('Expression Parser & Calculator Engine Tests', () {
    
    test('Basic Arithmetic', () {
      expect(CalculatorEngine.evaluate('12+34'), equals(46.0));
      expect(CalculatorEngine.evaluate('45−15'), equals(30.0));
      expect(CalculatorEngine.evaluate('12×3'), equals(36.0));
      expect(CalculatorEngine.evaluate('48÷6'), equals(8.0));
    });

    test('Operator Precedence (Shunting-Yard)', () {
      // 5 + 3 * 2 should be 11, NOT 16
      expect(CalculatorEngine.evaluate('5+3×2'), equals(11.0));
      // 10 - 2 * 3 + 4 / 2 should be 10 - 6 + 2 = 6
      expect(CalculatorEngine.evaluate('10−2×3+4÷2'), equals(6.0));
      // Exponents evaluate before multiplication
      expect(CalculatorEngine.evaluate('2×3^2'), equals(18.0));
    });

    test('Parentheses Evaluation', () {
      expect(CalculatorEngine.evaluate('(5+3)×2'), equals(16.0));
      expect(CalculatorEngine.evaluate('2×(3+4)÷2'), equals(7.0));
      expect(CalculatorEngine.evaluate('((2+3)×2)^2'), equals(100.0));
    });

    test('Decimal Numbers', () {
      expect(CalculatorEngine.evaluate('2.5×4'), equals(10.0));
      expect(CalculatorEngine.evaluate('1.25+2.75'), equals(4.0));
      expect(CalculatorEngine.evaluate('10÷4'), equals(2.5));
    });

    test('Negative Numbers & Unary Operations', () {
      expect(CalculatorEngine.evaluate('u-5+3'), equals(-2.0));
      expect(CalculatorEngine.evaluate('5×u-3'), equals(-15.0));
      // Nested unary signs
      expect(CalculatorEngine.evaluate('u-u-5'), equals(5.0));
    });

    test('Percentage & Suffix Operators', () {
      expect(CalculatorEngine.evaluate('50%'), equals(0.5));
      expect(CalculatorEngine.evaluate('5%×200'), equals(10.0));
      // Factorial
      expect(CalculatorEngine.evaluate('5!'), equals(120.0));
      expect(CalculatorEngine.evaluate('0!'), equals(1.0));
    });

    test('Scientific Functions', () {
      // Trigonometric (Radians)
      expect(CalculatorEngine.evaluate('sin(π÷2)'), closeTo(1.0, 1e-9));
      expect(CalculatorEngine.evaluate('cos(π)'), closeTo(-1.0, 1e-9));
      expect(CalculatorEngine.evaluate('tan(0)'), equals(0.0));
      
      // Inverse Trig
      expect(CalculatorEngine.evaluate('asin(1)'), closeTo(1.57079632679, 1e-9)); // pi/2
      
      // Logarithmic
      expect(CalculatorEngine.evaluate('log(100)'), equals(2.0));
      expect(CalculatorEngine.evaluate('ln(e)'), equals(1.0));
      
      // Roots
      expect(CalculatorEngine.evaluate('sqrt(144)'), equals(12.0));
      expect(CalculatorEngine.evaluate('cbrt(27)'), closeTo(3.0, 1e-9));
      expect(CalculatorEngine.evaluate('cbrt(u-8)'), closeTo(-2.0, 1e-9));
      
      // Abs
      expect(CalculatorEngine.evaluate('abs(u-15.5)'), equals(15.5));
    });

    test('Edge Cases & Errors Handling', () {
      // Division by zero
      expect(() => CalculatorEngine.evaluate('5÷0'), throwsA(isA<FormatException>()));
      
      // Invalid inputs
      expect(() => CalculatorEngine.evaluate('5++3'), throwsA(isA<FormatException>()));
      expect(() => CalculatorEngine.evaluate('sin('), throwsA(isA<FormatException>()));
      expect(() => CalculatorEngine.evaluate('(5+3'), throwsA(isA<FormatException>()));
      
      // Factorial of negative or decimals
      expect(() => CalculatorEngine.evaluate('(u-5)!'), throwsA(isA<FormatException>()));
      expect(() => CalculatorEngine.evaluate('5.5!'), throwsA(isA<FormatException>()));
    });

    test('Formatted Outputs', () {
      // Trailing zeros trim
      expect(CalculatorEngine.formatResult(5.00000000000000000), equals('5'));
      // Precision limits
      expect(CalculatorEngine.formatResult(3.1415926535, precision: 4), equals('3.1416'));
      // Thousands separator
      expect(CalculatorEngine.formatResult(1234567.89, useSeparator: true), equals('1,234,567.89'));
      expect(CalculatorEngine.formatResult(1234567.89, useSeparator: false), equals('1234567.89'));
    });
  });
}
