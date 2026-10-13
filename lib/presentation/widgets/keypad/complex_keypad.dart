import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/calculator_cubit.dart';
import 'calc_button.dart';

/// Complex number mode keypad
class ComplexKeypad extends StatelessWidget {
  const ComplexKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          // Row 1: Complex functions
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'i', type: CalcButtonType.function, onPressed: () {
                  cubit.inputConstant('i', 1);
                }),
                CalcButton(text: 'conj', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('conjugate(');
                }),
                CalcButton(text: 'abs', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('abs(');
                }),
                CalcButton(text: 'arg', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('arg(');
                }),
                CalcButton(text: 're', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('re(');
                }),
              ],
            ),
          ),
          // Row 2
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'im', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('im(');
                }),
                CalcButton(text: 'exp', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('exp(');
                }),
                CalcButton(text: 'ln', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('ln(');
                }),
                CalcButton(text: '√', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('sqrt(');
                }),
                CalcButton(text: 'sin', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('sin(');
                }),
              ],
            ),
          ),
          // Row 3
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'cos', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('cos(');
                }),
                CalcButton(text: 'tan', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('tan(');
                }),
                CalcButton(text: 'C', type: CalcButtonType.clear, onPressed: () => cubit.clearAll()),
                CalcButton(text: '⌫', type: CalcButtonType.function, onPressed: () => cubit.backspace()),
                CalcButton(text: '(', type: CalcButtonType.function, onPressed: () => cubit.inputParenthesis('(')),
              ],
            ),
          ),
          // Row 4: Digits
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '7', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('7')),
                CalcButton(text: '8', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('8')),
                CalcButton(text: '9', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('9')),
                CalcButton(text: '÷', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('/')),
                CalcButton(text: ')', type: CalcButtonType.function, onPressed: () => cubit.inputParenthesis(')')),
              ],
            ),
          ),
          // Row 5
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '4', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('4')),
                CalcButton(text: '5', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('5')),
                CalcButton(text: '6', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('6')),
                CalcButton(text: '×', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('*')),
                CalcButton(text: 'π', type: CalcButtonType.function, onPressed: () => cubit.inputConstant('π', 3.14159265)),
              ],
            ),
          ),
          // Row 6
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '1', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('1')),
                CalcButton(text: '2', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('2')),
                CalcButton(text: '3', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('3')),
                CalcButton(text: '−', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('-')),
                CalcButton(text: 'e', type: CalcButtonType.function, onPressed: () => cubit.inputConstant('e', 2.71828182)),
              ],
            ),
          ),
          // Row 7
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '±', type: CalcButtonType.function, onPressed: () => cubit.inputOperator('-')),
                CalcButton(text: '0', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('0')),
                CalcButton(text: '.', type: CalcButtonType.digit, onPressed: () => cubit.inputDecimal()),
                CalcButton(text: '+', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('+')),
                CalcButton(text: '=', type: CalcButtonType.equals, onPressed: () => cubit.evaluate()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
