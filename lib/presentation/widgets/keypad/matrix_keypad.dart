import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/calculator_cubit.dart';
import 'calc_button.dart';

/// Matrix operations keypad
class MatrixKeypad extends StatelessWidget {
  const MatrixKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Matrix operations
          SizedBox(
            height: 40,
            child: Row(
              children: [
                CalcButton(text: 'Aᵀ', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('transpose(');
                }),
                CalcButton(text: 'det(A)', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('determinant(');
                }),
                CalcButton(text: 'A⁻¹', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('inverse(');
                }),
                CalcButton(text: 'tr(A)', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('trace(');
                }),
                CalcButton(text: 'rank(A)', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('rank(');
                }),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                CalcButton(text: 'λ(A)', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('eigen(');
                }),
                CalcButton(text: 'Ax=b', type: CalcButtonType.scientific, onPressed: () {
                  cubit.inputFunction('solve(');
                }),
                CalcButton(text: 'I', type: CalcButtonType.function, onPressed: () {
                  cubit.inputFunction('identity(');
                }),
                CalcButton(text: '0', type: CalcButtonType.function, onPressed: () {
                  cubit.inputFunction('zeros(');
                }),
                CalcButton(text: 'diag', type: CalcButtonType.function, onPressed: () {
                  cubit.inputFunction('diag(');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
