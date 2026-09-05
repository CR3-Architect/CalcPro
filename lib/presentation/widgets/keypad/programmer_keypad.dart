import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/number_base.dart';
import '../../../core/theme/color_tokens.dart';
import '../../bloc/calculator_cubit.dart';
import '../../bloc/calculator_state.dart';
import 'calc_button.dart';

/// Programmer mode keypad
class ProgrammerKeypad extends StatelessWidget {
  const ProgrammerKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        children: [
          // Row 1: Base selectors
          BlocBuilder<CalculatorCubit, CalculatorState>(
            builder: (context, state) {
              return Expanded(
                child: Row(
                  children: [
                    _buildBaseButton('BIN', NumberBase.binary, state.numberBase, cubit),
                    _buildBaseButton('OCT', NumberBase.octal, state.numberBase, cubit),
                    _buildBaseButton('DEC', NumberBase.decimal, state.numberBase, cubit),
                    _buildBaseButton('HEX', NumberBase.hexadecimal, state.numberBase, cubit),
                  ],
                ),
              );
            },
          ),
          // Row 2: Bitwise operations
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'AND', type: CalcButtonType.scientific, onPressed: () => cubit.inputBitwiseOp('AND')),
                CalcButton(text: 'OR', type: CalcButtonType.scientific, onPressed: () => cubit.inputBitwiseOp('OR')),
                CalcButton(text: 'XOR', type: CalcButtonType.scientific, onPressed: () => cubit.inputBitwiseOp('XOR')),
                CalcButton(text: 'NOT', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('not(');
                }),
              ],
            ),
          ),
          // Row 3: Shifts and complement
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '<<', type: CalcButtonType.scientific, onPressed: () => cubit.inputBitwiseOp('<<')),
                CalcButton(text: '>>', type: CalcButtonType.scientific, onPressed: () => cubit.inputBitwiseOp('>>')),
                CalcButton(text: 'NAND', type: CalcButtonType.scientific, onPressed: () => cubit.inputBitwiseOp('NAND')),
                CalcButton(text: 'NOR', type: CalcButtonType.scientific, onPressed: () => cubit.inputBitwiseOp('NOR')),
              ],
            ),
          ),
          // Row 4: Hex digits (A-F) + 7 8 9
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'A', type: CalcButtonType.hexDigit, onPressed: () => cubit.inputHexDigit('A')),
                CalcButton(text: 'B', type: CalcButtonType.hexDigit, onPressed: () => cubit.inputHexDigit('B')),
                CalcButton(text: 'C', type: CalcButtonType.hexDigit, onPressed: () => cubit.inputHexDigit('C')),
                CalcButton(text: '7', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('7')),
                CalcButton(text: '8', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('8')),
                CalcButton(text: '9', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('9')),
                CalcButton(text: '÷', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('/')),
              ],
            ),
          ),
          // Row 5: Hex digits D-F + 4 5 6
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'D', type: CalcButtonType.hexDigit, onPressed: () => cubit.inputHexDigit('D')),
                CalcButton(text: 'E', type: CalcButtonType.hexDigit, onPressed: () => cubit.inputHexDigit('E')),
                CalcButton(text: 'F', type: CalcButtonType.hexDigit, onPressed: () => cubit.inputHexDigit('F')),
                CalcButton(text: '4', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('4')),
                CalcButton(text: '5', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('5')),
                CalcButton(text: '6', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('6')),
                CalcButton(text: '×', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('*')),
              ],
            ),
          ),
          // Row 6: Special + 1 2 3
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '2\'s', type: CalcButtonType.function, onPressed: () {
                  cubit.inputFunction('twos_complement(');
                }),
                CalcButton(text: '1\'s', type: CalcButtonType.function, onPressed: () {
                  cubit.inputFunction('ones_complement(');
                }),
                CalcButton(text: '0x', type: CalcButtonType.function, onPressed: () {
                  cubit.inputHexDigit('0');
                  cubit.inputHexDigit('x');
                }),
                CalcButton(text: '1', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('1')),
                CalcButton(text: '2', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('2')),
                CalcButton(text: '3', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('3')),
                CalcButton(text: '−', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('-')),
              ],
            ),
          ),
          // Row 7: Bottom row
          Expanded(
            child: Row(
              children: [
                CalcButton(text: 'C', type: CalcButtonType.clear, onPressed: () => cubit.clearAll()),
                CalcButton(text: '0', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('0')),
                CalcButton(text: '1', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('1')),
                CalcButton(text: '.', type: CalcButtonType.digit, onPressed: () => cubit.inputDecimal()),
                CalcButton(text: '+', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('+')),
              ],
            ),
          ),
          // Row 8: Bottom row 2
          Expanded(
            child: Row(
              children: [
                CalcButton(text: '⌫', type: CalcButtonType.function, onPressed: () => cubit.backspace()),
                CalcButton(text: 'pop', type: CalcButtonType.function, onPressed: () {}),
                CalcButton(text: 'clz', type: CalcButtonType.function, onPressed: () {}),
                CalcButton(text: '±', type: CalcButtonType.function, onPressed: () => cubit.inputOperator('-')),
                CalcButton(text: '=', type: CalcButtonType.equals, onPressed: () => cubit.evaluate()),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBaseButton(String label, NumberBase base, NumberBase current, CalculatorCubit cubit) {
    final isActive = base == current;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: () => cubit.setNumberBase(base),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isActive
                  ? ColorTokens.electricCyan.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? ColorTokens.electricCyan : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? ColorTokens.electricCyan : null,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
