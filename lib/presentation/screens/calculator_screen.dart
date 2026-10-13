import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/enums/calc_mode.dart';
import '../../core/theme/color_tokens.dart';
import '../bloc/calculator_cubit.dart';
import '../bloc/calculator_state.dart';
import '../widgets/display/expression_display.dart';
import '../widgets/display/result_display.dart';
import '../widgets/display/history_tape.dart';
import '../widgets/keypad/standard_keypad.dart';
import '../widgets/keypad/scientific_keypad.dart';
import '../widgets/keypad/calculus_keypad.dart';
import '../widgets/keypad/matrix_keypad.dart';
import '../widgets/keypad/programmer_keypad.dart';
import '../widgets/keypad/complex_keypad.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'unit_converter_screen.dart';
import 'matrix_editor_screen.dart';
import 'stats_input_screen.dart';

/// Main calculator screen
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  void _openModeSheet(BuildContext context, CalcMode current) {
    final cubit = context.read<CalculatorCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(sheetCtx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Calculator Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(sheetCtx).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            for (final mode in CalcMode.values)
              ListTile(
                dense: true,
                leading: Icon(
                  mode == current ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: mode == current ? ColorTokens.electricCyan : null,
                  size: 22,
                ),
                title: Text(mode.displayName),
                subtitle: Text(
                  mode.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  cubit.setMode(mode);
                  Navigator.pop(sheetCtx);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (prev, curr) => prev.mode != curr.mode,
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final fg = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;

        return Scaffold(
          backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
          body: SafeArea(
            child: Column(
              children: [
                // --- Top Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      // Mode selector button
                      Material(
                        color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _openModeSheet(context, state.mode),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.mode.displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: fg,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.expand_more_rounded, size: 20, color: fg.withOpacity(0.6)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Undo
                      BlocBuilder<CalculatorCubit, CalculatorState>(
                        buildWhen: (p, c) => p.canUndo != c.canUndo,
                        builder: (context, s) => IconButton(
                          onPressed: s.canUndo ? () => context.read<CalculatorCubit>().undo() : null,
                          icon: const Icon(Icons.undo_rounded, size: 20),
                          color: fg,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      // Redo
                      BlocBuilder<CalculatorCubit, CalculatorState>(
                        buildWhen: (p, c) => p.canRedo != c.canRedo,
                        builder: (context, s) => IconButton(
                          onPressed: s.canRedo ? () => context.read<CalculatorCubit>().redo() : null,
                          icon: const Icon(Icons.redo_rounded, size: 20),
                          color: fg,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                        icon: const Icon(Icons.history_rounded, size: 21),
                        color: fg,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        icon: const Icon(Icons.settings_rounded, size: 21),
                        color: fg,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),

                // --- Display ---
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(flex: 1, child: HistoryTape()),
                        SizedBox(height: 2),
                        Expanded(flex: 1, child: ExpressionDisplay()),
                        SizedBox(height: 2),
                        Expanded(flex: 2, child: ResultDisplay()),
                      ],
                    ),
                  ),
                ),

                // --- Keypad ---
                Expanded(
                  flex: 5,
                  child: _KeypadArea(mode: state.mode),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KeypadArea extends StatelessWidget {
  final CalcMode mode;
  const _KeypadArea({required this.mode});

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case CalcMode.standard:
        return const StandardKeypad();
      case CalcMode.scientific:
        return const ScientificKeypad();
      case CalcMode.calculus:
        return const CalculusKeypad();
      case CalcMode.matrix:
        return _MatrixSection(context);
      case CalcMode.complex:
        return const ComplexKeypad();
      case CalcMode.stats:
        return _StatsSection(context);
      case CalcMode.programmer:
        return const ProgrammerKeypad();
      case CalcMode.unitConverter:
        return _ConverterSection(context);
    }
  }

  static Widget _MatrixSection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_on_rounded, size: 44, color: ColorTokens.accentBlue.withOpacity(0.5)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatrixEditorScreen())),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open Matrix Editor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: MatrixKeypad(),
          ),
        ],
      ),
    );
  }

  static Widget _StatsSection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_rounded, size: 44, color: ColorTokens.accentGreen.withOpacity(0.5)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsInputScreen())),
            icon: const Icon(Icons.table_chart, size: 18),
            label: const Text('Open Data Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _ConverterSection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz_rounded, size: 44, color: ColorTokens.accentPurple.withOpacity(0.5)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitConverterScreen())),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open Unit Converter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
