import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/color_tokens.dart';
import '../../bloc/calculator_cubit.dart';
import 'calc_button.dart';

/// Standard calculator — compact, professional, expandable scientific panel
class StandardKeypad extends StatefulWidget {
  const StandardKeypad({super.key});

  @override
  State<StandardKeypad> createState() => _StandardKeypadState();
}

class _StandardKeypadState extends State<StandardKeypad> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();

    return Column(
      children: [
        // --- Expand handle ---
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 22,
            child: Center(
              child: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 22,
                  color: ColorTokens.electricCyan.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),

        // --- Scientific panel (shares space when open) ---
        if (_expanded)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CalcButton(text: 'sin', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('sin(')),
                        CalcButton(text: 'cos', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('cos(')),
                        CalcButton(text: 'tan', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('tan(')),
                        CalcButton(text: 'ln', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('ln(')),
                        CalcButton(text: 'log', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('log(')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        CalcButton(text: '√', type: CalcButtonType.scientific, onPressed: () => cubit.inputFunction('sqrt(')),
                        CalcButton(text: 'x²', type: CalcButtonType.scientific, onPressed: () {
                          cubit.inputOperator('^');
                          cubit.inputDigit('2');
                        }),
                        CalcButton(text: 'xʸ', type: CalcButtonType.scientific, onPressed: () => cubit.inputOperator('^')),
                        CalcButton(text: 'n!', type: CalcButtonType.scientific, onPressed: () => cubit.inputOperator('!')),
                        CalcButton(text: 'π', type: CalcButtonType.scientific, onPressed: () => cubit.inputConstant('π', 3.141592653589793)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // --- Main 4x5 keypad ---
        Expanded(
          flex: _expanded ? 5 : 7,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(text: 'AC', type: CalcButtonType.clear, onPressed: () => cubit.clearAll()),
                      CalcButton(icon: Icons.backspace_outlined, text: '', type: CalcButtonType.function, onPressed: () => cubit.backspace()),
                      CalcButton(text: '%', type: CalcButtonType.function, onPressed: () => cubit.inputPercent()),
                      CalcButton(text: '÷', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('/')),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(text: '7', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('7')),
                      CalcButton(text: '8', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('8')),
                      CalcButton(text: '9', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('9')),
                      CalcButton(text: '×', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('*')),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(text: '4', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('4')),
                      CalcButton(text: '5', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('5')),
                      CalcButton(text: '6', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('6')),
                      CalcButton(text: '−', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('-')),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(text: '1', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('1')),
                      CalcButton(text: '2', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('2')),
                      CalcButton(text: '3', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('3')),
                      CalcButton(text: '+', type: CalcButtonType.operator, onPressed: () => cubit.inputOperator('+')),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(text: '±', type: CalcButtonType.function, onPressed: () => cubit.inputOperator('-')),
                      CalcButton(text: '0', type: CalcButtonType.digit, onPressed: () => cubit.inputDigit('0')),
                      CalcButton(text: '.', type: CalcButtonType.digit, onPressed: () => cubit.inputDecimal()),
                      CalcButton(text: '=', type: CalcButtonType.equals, onPressed: () => cubit.evaluate()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
