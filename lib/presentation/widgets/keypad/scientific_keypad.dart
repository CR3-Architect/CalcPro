import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/calculator_cubit.dart';
import 'calc_button.dart';

/// Scientific calculator keypad
class ScientificKeypad extends StatefulWidget {
  const ScientificKeypad({super.key});

  @override
  State<ScientificKeypad> createState() => _ScientificKeypadState();
}

class _ScientificKeypadState extends State<ScientificKeypad> {
  bool _showInverse = false;
  bool _showHyperbolic = false;
  
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        children: [
          // Row 1: Trig functions
          Expanded(
            child: Row(
              children: [
                _buildTrigButton('sin', cubit),
                _buildTrigButton('cos', cubit),
                _buildTrigButton('tan', cubit),
                CalcButton(
                  text: _showInverse ? 'INV' : 'INV',
                  type: CalcButtonType.function,
                  onPressed: () => setState(() => _showInverse = !_showInverse),
                ),
                CalcButton(
                  text: _showHyperbolic ? 'HYP' : 'HYP',
                  type: CalcButtonType.function,
                  onPressed: () => setState(() => _showHyperbolic = !_showHyperbolic),
                ),
              ],
            ),
          ),
          // Row 2: Log/exp functions
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'log₁₀', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('log(')),
                CalcButton(text: 'ln', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('ln(')),
                CalcButton(text: 'xⁿ', type: CalcButtonType.scientific, onPressed: () => cubit.inputOperator('^')),
                CalcButton(text: 'eˣ', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('exp(')),
                CalcButton(text: '10ˣ', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('pow(');
                  cubit.inputDigit('1');
                  cubit.inputDigit('0');
                  cubit.inputOperator(',');
                }),
              ],
            ),
          ),
          // Row 3: Other functions
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'n!', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('factorial(')),
                CalcButton(text: '|x|', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('abs(')),
                CalcButton(text: '⌊x⌋', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('floor(')),
                CalcButton(text: '⌈x⌉', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('ceil(')),
                CalcButton(text: 'φ', type: CalcButtonType.scientific, onPressed: () => cubit.inputConstant('φ', 1.61803399)),
              ],
            ),
          ),
          // Row 4: nPr nCr log_a sqrt
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'nPr', type: CalcButtonType.function, onPressed: () => cubit.inputFunction('nPr(')),
                CalcButton(text: 'nCr', type: CalcButtonType.function, onPressed: () => cubit.inputFunction('nCr(')),
                CalcButton(text: 'ⁿ√x', type: CalcButtonType.function, onPressed: () => cubit.inputFunction('root(')),
                CalcButton(text: 'logₐ', type: CalcButtonType.function, onPressed: () => cubit.inputFunction('log(')),
                CalcButton(text: 'π', type: CalcButtonType.function, onPressed: () => cubit.inputConstant('π', 3.14159265)),
              ],
            ),
          ),
          // Row 5: Standard digits and operators
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'C', type: CalcButtonType.clear, onPressed: () => cubit.clearAll()),
                CalcButton(text: '7', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('7')),
                CalcButton(text: '8', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('8')),
                CalcButton(text: '9', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('9')),
                CalcButton(text: '÷', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('/')),
              ],
            ),
          ),
          // Row 6
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '⌫', type: CalcButtonType.function, onPressed: () => cubit.backspace()),
                CalcButton(text: '4', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('4')),
                CalcButton(text: '5', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('5')),
                CalcButton(text: '6', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('6')),
                CalcButton(text: '×', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('*')),
              ],
            ),
          ),
          // Row 7
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '%', type: CalcButtonType.function, onPressed: () => cubit.inputPercent()),
                CalcButton(text: '1', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('1')),
                CalcButton(text: '2', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('2')),
                CalcButton(text: '3', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('3')),
                CalcButton(text: '−', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('-')),
              ],
            ),
          ),
          // Row 8
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'e', type: CalcButtonType.function, onPressed: () => cubit.inputConstant('e', 2.71828182)),
                CalcButton(text: '0', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('0')),
                CalcButton(text: '.', type: CalcButtonType.digit, onPressed: () => cubit.inputDecimal()),
                CalcButton(text: '(', type: CalcButtonType.function, onPressed: () => cubit.inputParenthesis('(')),
                CalcButton(text: '+', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('+')),
              ],
            ),
          ),
          // Row 9
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'x²', type: CalcButtonType.function, onPressed: () {
                  cubit.inputOperator('^');
                  cubit.inputDigit('2');
                }),
                CalcButton(text: '√', type: CalcButtonType.function, onPressed: () => cubit.inputFunction('sqrt(')),
                CalcButton(text: ')', type: CalcButtonType.function, onPressed: () => cubit.inputParenthesis(')')),
                CalcButton(text: '±', type: CalcButtonType.function, onPressed: () => cubit.inputOperator('-')),
                CalcButton(text: '=', type: CalcButtonType.equals, onPressed: () => cubit.evaluate()),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrigButton(String func, CalculatorCubit cubit) {
    String label;
    String callFunc;
    
    if (_showHyperbolic) {
      if (_showInverse) {
        label = '${func.substring(0, 2)}⁻¹h';
        callFunc = 'a${func.substring(0, 3)}h(';
      } else {
        label = '${func.substring(0, 3)}h';
        callFunc = '${func.substring(0, 3)}h(';
      }
    } else {
      if (_showInverse) {
        label = '${func.substring(0, 2)}⁻¹';
        callFunc = 'a${func.substring(0, 3)}(';
      } else {
        label = func;
        callFunc = '$func(';
      }
    }
    
    return CalcButton(
      text: label,
      type: CalcButtonType.scientific,
      onPressed: () => cubit.inputFunction(callFunc),
    );
  }
}
