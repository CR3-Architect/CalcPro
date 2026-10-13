import 'package:flutter/material.dart';

import '../../screens/matrix_editor_screen.dart';
import 'calc_button.dart';

/// Matrix operations keypad — opens the visual matrix editor
class MatrixKeypad extends StatelessWidget {
  const MatrixKeypad({super.key});

  void _openEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MatrixEditorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Matrix operations → open editor
          SizedBox(
            height: 40,
            child: Row(
              children: [
                CalcButton(text: 'Aᵀ', type: CalcButtonType.scientific, onPressed: () => _openEditor(context)),
                CalcButton(text: 'det(A)', type: CalcButtonType.scientific, onPressed: () => _openEditor(context)),
                CalcButton(text: 'A⁻¹', type: CalcButtonType.scientific, onPressed: () => _openEditor(context)),
                CalcButton(text: 'tr(A)', type: CalcButtonType.scientific, onPressed: () => _openEditor(context)),
                CalcButton(text: 'rank(A)', type: CalcButtonType.scientific, onPressed: () => _openEditor(context)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                CalcButton(text: 'λ(A)', type: CalcButtonType.scientific, onPressed: () => _openEditor(context)),
                CalcButton(text: 'Ax=b', type: CalcButtonType.scientific, onPressed: () => _openEditor(context)),
                CalcButton(text: 'I', type: CalcButtonType.function, onPressed: () => _openEditor(context)),
                CalcButton(text: '0', type: CalcButtonType.function, onPressed: () => _openEditor(context)),
                CalcButton(text: 'diag', type: CalcButtonType.function, onPressed: () => _openEditor(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
