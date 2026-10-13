import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/calculator_cubit.dart';
import 'calc_button.dart';

/// Standard calculator keypad
class StandardKeypad extends StatelessWidget {
  const StandardKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          // Row 1: Memory + Clear
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'MC', type: CalcButtonType.memory, onPressed: () => cubit.memoryClear()),
                CalcButton(text: 'MR', type: CalcButtonType.memory, onPressed: () => cubit.memoryRecall()),
                CalcButton(text: 'M-', type: CalcButtonType.memory, onPressed: () => cubit.memorySubtract()),
                CalcButton(text: 'M+', type: CalcButtonType.memory, onPressed: () => cubit.memoryAdd()),
                CalcButton(text: 'C', type: CalcButtonType.clear, onPressed: () => cubit.clearAll()),
              ],
            ),
          ),
          // Row 2: %, √, x², ÷
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '%', type: CalcButtonType.function, onPressed: () => cubit.inputPercent()),
                CalcButton(text: '√', type: CalcButtonType.function, onPressed: () => cubit.inputFunction('sqrt(')),
                CalcButton(text: 'x²', type: CalcButtonType.function, onPressed: () {
                  cubit.inputOperator('^');
                  cubit.inputDigit('2');
                }),
                CalcButton(text: '÷', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('/')),
                CalcButton(text: '⌫', type: CalcButtonType.function, onPressed: () => cubit.backspace(), icon: Icons.backspace_outlined),
              ],
            ),
          ),
          // Row 3: 7, 8, 9, ×
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '7', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('7')),
                CalcButton(text: '8', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('8')),
                CalcButton(text: '9', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('9')),
                CalcButton(text: '×', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('*')),
                CalcButton(text: '(', type: CalcButtonType.function, onPressed: () => cubit.inputParenthesis('(')),
              ],
            ),
          ),
          // Row 4: 4, 5, 6, −
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '4', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('4')),
                CalcButton(text: '5', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('5')),
                CalcButton(text: '6', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('6')),
                CalcButton(text: '−', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('-')),
                CalcButton(text: ')', type: CalcButtonType.function, onPressed: () => cubit.inputParenthesis(')')),
              ],
            ),
          ),
          // Row 5: 1, 2, 3, +
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '1', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('1')),
                CalcButton(text: '2', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('2')),
                CalcButton(text: '3', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('3')),
                CalcButton(text: '+', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('+')),
                CalcButton(text: 'π', type: CalcButtonType.function, onPressed: () => cubit.inputConstant('π', 3.14159265)),
              ],
            ),
          ),
          // Row 6: ±, 0, ., e, =
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '±', type: CalcButtonType.function, onPressed: () => cubit.inputOperator('-'), icon: Icons.add, ),
                CalcButton(text: '0', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('0')),
                CalcButton(text: '.', type: CalcButtonType.digit, onPressed: () => cubit.inputDecimal()),
                CalcButton(text: 'e', type: CalcButtonType.function, onPressed: () => cubit.inputConstant('e', 2.71828182)),
                CalcButton(text: '=', type: CalcButtonType.equals, onPressed: () => cubit.evaluate()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
