import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/calculator_cubit.dart';
import 'calc_button.dart';

/// Calculus & Analysis keypad
class CalculusKeypad extends StatelessWidget {
  const CalculusKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        children: [
          // Row 1: Calculus functions
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'd/dx', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('derivative(');
                }),
                CalcButton(text: '∫', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('integrate(');
                }),
                CalcButton(text: 'lim', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('limit(');
                }),
                CalcButton(text: 'Σ', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('sum(');
                }),
                CalcButton(text: 'Π', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('product(');
                }),
              ],
            ),
          ),
          // Row 2: Series and ODE
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'Taylor', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('taylor(');
                }),
                CalcButton(text: 'ODE', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('ode(');
                }),
                CalcButton(text: 'ln', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('ln(');
                }),
                CalcButton(text: 'eˣ', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('exp(');
                }),
                CalcButton(text: 'xⁿ', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputOperator('^');
                }),
              ],
            ),
          ),
          // Row 3: Trig
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'sin', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('sin(');
                }),
                CalcButton(text: 'cos', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('cos(');
                }),
                CalcButton(text: 'tan', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('tan(');
                }),
                CalcButton(text: '√', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('sqrt(');
                }),
                CalcButton(text: '|x|', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('abs(');
                }),
              ],
            ),
          ),
          // Row 4: Constants
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'π', type: CalcButtonType.function, onPressed: () {
                  cubit.inputConstant('π', 3.14159265);
                }),
                CalcButton(text: 'e', type: CalcButtonType.function, onPressed: () {
                  cubit.inputConstant('e', 2.71828182);
                }),
                CalcButton(text: '(', type: CalcButtonType.function, onPressed: () {
                  cubit.inputParenthesis('(');
                }),
                CalcButton(text: ')', type: CalcButtonType.function, onPressed: () {
                  cubit.inputParenthesis(')');
                }),
                CalcButton(text: ',', type: CalcButtonType.function, onPressed: () {
                  cubit.inputOperator(',');
                }),
              ],
            ),
          ),
          // Row 5: Digits
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
                CalcButton(text: 'n!', type: CalcButtonType.function, onPressed: () {
                  cubit.inputFunction('factorial(');
                }),
                CalcButton(text: '0', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('0')),
                CalcButton(text: '.', type: CalcButtonType.digit, onPressed: () => cubit.inputDecimal()),
                CalcButton(text: 'x', type: CalcButtonType.function, onPressed: () => cubit.inputConstant('x', 0)),
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
                CalcButton(text: 'x³', type: CalcButtonType.function, onPressed: () {
                  cubit.inputOperator('^');
                  cubit.inputDigit('3');
                }),
                CalcButton(text: '1/x', type: CalcButtonType.function, onPressed: () {
                  cubit.inputOperator('^');
                  cubit.inputOperator('-');
                  cubit.inputDigit('1');
                }),
                CalcButton(text: '±', type: CalcButtonType.function, onPressed: () => cubit.inputOperator('-')),
                CalcButton(text: '=', type: CalcButtonType.equals, onPressed: () => cubit.evaluate()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
