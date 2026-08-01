import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator_button.dart';

class CalculatorKeyboard extends StatelessWidget {
  const CalculatorKeyboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calcProvider = Provider.of<CalculatorProvider>(context);
    
    // We get the parent layout orientation and size to decide grid configurations
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isLandscape = width > 500;
        
        return Column(
          children: [
            // Memory functions row
            _buildMemoryRow(context, calcProvider),
            const SizedBox(height: 4.0),
            
            // Dynamic Grid Layout
           Expanded(
              child: calcProvider.isScientific
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildFullKeyboard(
                        context,
                        calcProvider,
                        isLandscape,
                        ),
                      )
                    : _buildBasicKeyboard(
                        context,
                        calcProvider,
                        ),
              ),
          ],
        );
      },
    );
  }

  // Memory functions bar (MC, MR, M+, M-, MS)
  Widget _buildMemoryRow(BuildContext context, CalculatorProvider provider) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.primary,
    );

    final List<Map<String, VoidCallback>> memBtns = [
      {'MC': provider.memoryClear},
      {'MR': provider.memoryRecall},
      {'M+': provider.memoryAdd},
      {'M-': provider.memorySubtract},
      {'MS': provider.memoryStore},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: memBtns.map((btn) {
        final label = btn.keys.first;
        final callback = btn.values.first;
        return TextButton(
          onPressed: callback,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(label, style: textStyle),
        );
      }).toList(),
    );
  }

  // Regular portrait keyboard layout
  Widget _buildBasicKeyboard(BuildContext context, CalculatorProvider provider) {
    final List<Widget> rows = [
      // Row 1
      _buildRow([
        CalculatorButton(text: 'AC', type: ButtonType.function, onTap: provider.clear),
        CalculatorButton(text: '±', type: ButtonType.function, onTap: provider.toggleSign),
        CalculatorButton(text: '%', type: ButtonType.function, onTap: () => provider.append('%')),
        CalculatorButton(text: '÷', type: ButtonType.operator, onTap: () => provider.append('÷')),
      ]),
      // Row 2
      _buildRow([
        CalculatorButton(text: '7', onTap: () => provider.append('7')),
        CalculatorButton(text: '8', onTap: () => provider.append('8')),
        CalculatorButton(text: '9', onTap: () => provider.append('9')),
        CalculatorButton(text: '×', type: ButtonType.operator, onTap: () => provider.append('×')),
      ]),
      // Row 3
      _buildRow([
        CalculatorButton(text: '4', onTap: () => provider.append('4')),
        CalculatorButton(text: '5', onTap: () => provider.append('5')),
        CalculatorButton(text: '6', onTap: () => provider.append('6')),
        CalculatorButton(text: '−', type: ButtonType.operator, onTap: () => provider.append('−')),
      ]),
      // Row 4
      _buildRow([
        CalculatorButton(text: '1', onTap: () => provider.append('1')),
        CalculatorButton(text: '2', onTap: () => provider.append('2')),
        CalculatorButton(text: '3', onTap: () => provider.append('3')),
        CalculatorButton(text: '+', type: ButtonType.operator, onTap: () => provider.append('+')),
      ]),
      // Row 5
      _buildRow([
        CalculatorButton(text: '0', onTap: () => provider.append('0')),
        CalculatorButton(text: '.', onTap: () => provider.append('.')),
        CalculatorButton(text: '⌫', type: ButtonType.function, onTap: provider.backspace),
        CalculatorButton(text: '=', type: ButtonType.equal, onTap: provider.evaluate),
      ]),
    ];

    return Column(
      children: rows.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: row,
      )).toList(),
    );
  }

  // Expanded layout (basic side-by-side or stacked with scientific buttons)
  Widget _buildFullKeyboard(BuildContext context, CalculatorProvider provider, bool isLandscape) {
    if (isLandscape) {
      // Side-by-side 8 column layout (Scientific on left, Basic on right)
      return Column(
        children: [
          _buildRow([
            CalculatorButton(text: '(', type: ButtonType.scientific, onTap: () => provider.append('(')),
            CalculatorButton(text: ')', type: ButtonType.scientific, onTap: () => provider.append(')')),
            CalculatorButton(text: 'abs', type: ButtonType.scientific, onTap: () => provider.append('abs(')),
            CalculatorButton(text: '1/x', type: ButtonType.scientific, onTap: () => provider.append('1÷(')),
            CalculatorButton(text: 'AC', type: ButtonType.function, onTap: provider.clear),
            CalculatorButton(text: '±', type: ButtonType.function, onTap: provider.toggleSign),
            CalculatorButton(text: '%', type: ButtonType.function, onTap: () => provider.append('%')),
            CalculatorButton(text: '÷', type: ButtonType.operator, onTap: () => provider.append('÷')),
          ]),
          const SizedBox(height: 6.0),
          _buildRow([
            CalculatorButton(text: 'sin', type: ButtonType.scientific, onTap: () => provider.append('sin(')),
            CalculatorButton(text: 'cos', type: ButtonType.scientific, onTap: () => provider.append('cos(')),
            CalculatorButton(text: 'tan', type: ButtonType.scientific, onTap: () => provider.append('tan(')),
            CalculatorButton(text: 'x^y', type: ButtonType.scientific, onTap: () => provider.append('^')),
            CalculatorButton(text: '7', onTap: () => provider.append('7')),
            CalculatorButton(text: '8', onTap: () => provider.append('8')),
            CalculatorButton(text: '9', onTap: () => provider.append('9')),
            CalculatorButton(text: '×', type: ButtonType.operator, onTap: () => provider.append('×')),
          ]),
          const SizedBox(height: 6.0),
          _buildRow([
            CalculatorButton(text: 'asin', type: ButtonType.scientific, onTap: () => provider.append('asin(')),
            CalculatorButton(text: 'acos', type: ButtonType.scientific, onTap: () => provider.append('acos(')),
            CalculatorButton(text: 'atan', type: ButtonType.scientific, onTap: () => provider.append('atan(')),
            CalculatorButton(text: 'x!', type: ButtonType.scientific, onTap: () => provider.append('!')),
            CalculatorButton(text: '4', onTap: () => provider.append('4')),
            CalculatorButton(text: '5', onTap: () => provider.append('5')),
            CalculatorButton(text: '6', onTap: () => provider.append('6')),
            CalculatorButton(text: '−', type: ButtonType.operator, onTap: () => provider.append('−')),
          ]),
          const SizedBox(height: 6.0),
          _buildRow([
            CalculatorButton(text: 'log', type: ButtonType.scientific, onTap: () => provider.append('log(')),
            CalculatorButton(text: 'ln', type: ButtonType.scientific, onTap: () => provider.append('ln(')),
            CalculatorButton(text: 'sqrt', type: ButtonType.scientific, onTap: () => provider.append('sqrt(')),
            CalculatorButton(text: 'π', type: ButtonType.scientific, onTap: () => provider.append('π')),
            CalculatorButton(text: '1', onTap: () => provider.append('1')),
            CalculatorButton(text: '2', onTap: () => provider.append('2')),
            CalculatorButton(text: '3', onTap: () => provider.append('3')),
            CalculatorButton(text: '+', type: ButtonType.operator, onTap: () => provider.append('+')),
          ]),
          const SizedBox(height: 6.0),
          _buildRow([
            CalculatorButton(text: 'cbrt', type: ButtonType.scientific, onTap: () => provider.append('cbrt(')),
            CalculatorButton(text: 'x²', type: ButtonType.scientific, onTap: () => provider.append('^2')),
            CalculatorButton(text: '10^x', type: ButtonType.scientific, onTap: () => provider.append('10^')),
            CalculatorButton(text: 'e', type: ButtonType.scientific, onTap: () => provider.append('e')),
            CalculatorButton(text: '0', onTap: () => provider.append('0')),
            CalculatorButton(text: '.', onTap: () => provider.append('.')),
            CalculatorButton(text: '⌫', type: ButtonType.function, onTap: provider.backspace),
            CalculatorButton(text: '=', type: ButtonType.equal, onTap: provider.evaluate),
          ]),
        ],
      );
    } else {
      // Portrait Scientific mode: Stacked layouts (Scientific grid on top, Basic grid below)
      return Column(
        children: [
          // Scientific buttons grid
          _buildRow([
            CalculatorButton(text: '(', type: ButtonType.scientific, onTap: () => provider.append('(')),
            CalculatorButton(text: ')', type: ButtonType.scientific, onTap: () => provider.append(')')),
            CalculatorButton(text: 'abs', type: ButtonType.scientific, onTap: () => provider.append('abs(')),
            CalculatorButton(text: '1/x', type: ButtonType.scientific, onTap: () => provider.append('1÷(')),
          ]),
          const SizedBox(height: 4.0),
          _buildRow([
            CalculatorButton(text: 'sin', type: ButtonType.scientific, onTap: () => provider.append('sin(')),
            CalculatorButton(text: 'cos', type: ButtonType.scientific, onTap: () => provider.append('cos(')),
            CalculatorButton(text: 'tan', type: ButtonType.scientific, onTap: () => provider.append('tan(')),
            CalculatorButton(text: 'x^y', type: ButtonType.scientific, onTap: () => provider.append('^')),
          ]),
          const SizedBox(height: 4.0),
          _buildRow([
            CalculatorButton(text: 'asin', type: ButtonType.scientific, onTap: () => provider.append('asin(')),
            CalculatorButton(text: 'acos', type: ButtonType.scientific, onTap: () => provider.append('acos(')),
            CalculatorButton(text: 'atan', type: ButtonType.scientific, onTap: () => provider.append('atan(')),
            CalculatorButton(text: 'x!', type: ButtonType.scientific, onTap: () => provider.append('!')),
          ]),
          const SizedBox(height: 4.0),
          _buildRow([
            CalculatorButton(text: 'log', type: ButtonType.scientific, onTap: () => provider.append('log(')),
            CalculatorButton(text: 'ln', type: ButtonType.scientific, onTap: () => provider.append('ln(')),
            CalculatorButton(text: 'sqrt', type: ButtonType.scientific, onTap: () => provider.append('sqrt(')),
            CalculatorButton(text: 'π', type: ButtonType.scientific, onTap: () => provider.append('π')),
          ]),
          const SizedBox(height: 4.0),
          _buildRow([
            CalculatorButton(text: 'cbrt', type: ButtonType.scientific, onTap: () => provider.append('cbrt(')),
            CalculatorButton(text: 'x²', type: ButtonType.scientific, onTap: () => provider.append('^2')),
            CalculatorButton(text: '10^x', type: ButtonType.scientific, onTap: () => provider.append('10^')),
            CalculatorButton(text: 'e', type: ButtonType.scientific, onTap: () => provider.append('e')),
          ]),
          
          // Divider between scientific and basic
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1.0, thickness: 1.0),
          ),
          
          // Basic buttons grid
          _buildBasicKeyboard(context, provider),
        ],
      );
    }
  }

  // Row helper
  Widget _buildRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children.map((child) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: child,
        ),
      )).toList(),
    );
  }
}
