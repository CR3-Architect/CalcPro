import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/enums/calc_mode.dart';
import '../../core/theme/color_tokens.dart';
import '../../core/utils/share_image_service.dart';
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
import 'currency_converter_screen.dart';
import 'matrix_editor_screen.dart';
import 'stats_input_screen.dart';

/// Main calculator screen
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final GlobalKey _displayKey = GlobalKey();

  void _openModeSheet(BuildContext context, CalcMode current) {
    final cubit = context.read<CalculatorCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    final subFg = isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface;
    final surface = isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface;
    final surfaceVar = isDark ? ColorTokens.darkSurfaceVariant : ColorTokens.lightSurfaceVariant;

    final icons = <CalcMode, IconData>{
      CalcMode.standard: Icons.calculate_outlined,
      CalcMode.scientific: Icons.science_outlined,
      CalcMode.calculus: Icons.functions,
      CalcMode.matrix: Icons.grid_on_rounded,
      CalcMode.complex: Icons.all_inclusive_rounded,
      CalcMode.stats: Icons.bar_chart_rounded,
      CalcMode.programmer: Icons.code_rounded,
      CalcMode.unitConverter: Icons.swap_horiz_rounded,
      CalcMode.currency: Icons.currency_exchange_rounded,
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: fg.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: Row(
                    children: [
                      Text(
                        'Calculator Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ColorTokens.electricCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '9 modes',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ColorTokens.electricCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Mode grid
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: CalcMode.values.length,
                    itemBuilder: (ctx, i) {
                      final mode = CalcMode.values[i];
                      final selected = mode == current;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(sheetCtx);
                            cubit.setMode(mode);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? ColorTokens.electricCyan.withOpacity(0.12)
                                  : surfaceVar.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? ColorTokens.electricCyan
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ColorTokens.electricCyan
                                        .withOpacity(selected ? 0.2 : 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icons[mode] ?? Icons.calculate_outlined,
                                    size: 22,
                                    color: ColorTokens.electricCyan,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  mode.displayName,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight:
                                        selected ? FontWeight.w700 : FontWeight.w500,
                                    color: fg,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                // --- Top Bar (compact) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        // Mode chip
                        Material(
                          color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _openModeSheet(context, state.mode),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.mode.displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: fg,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.expand_more_rounded, size: 18, color: fg.withOpacity(0.5)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        BlocBuilder<CalculatorCubit, CalculatorState>(
                          buildWhen: (p, c) => p.canUndo != c.canUndo,
                          builder: (context, s) => IconButton(
                            onPressed: s.canUndo ? () => context.read<CalculatorCubit>().undo() : null,
                            icon: const Icon(Icons.undo_rounded, size: 19),
                            color: fg,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ),
                        BlocBuilder<CalculatorCubit, CalculatorState>(
                          buildWhen: (p, c) => p.canRedo != c.canRedo,
                          builder: (context, s) => IconButton(
                            onPressed: s.canRedo ? () => context.read<CalculatorCubit>().redo() : null,
                            icon: const Icon(Icons.redo_rounded, size: 19),
                            color: fg,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                          icon: const Icon(Icons.history_rounded, size: 20),
                          color: fg,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                        IconButton(
                          onPressed: () => ShareImageService.captureAndShare(
                            context,
                            _displayKey,
                            text: state.result.isEmpty ? 'CalcPro Studio' : 'Result: ${state.formattedResult}',
                          ),
                          icon: const Icon(Icons.ios_share_rounded, size: 19),
                          color: fg,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          tooltip: 'Share as image',
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                          icon: const Icon(Icons.settings_rounded, size: 20),
                          color: fg,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Display (compact) ---
                Expanded(
                  flex: 2,
                  child: RepaintBoundary(
                    key: _displayKey,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      decoration: BoxDecoration(
                        color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
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
                ),

                // --- Keypad ---
                Expanded(
                  flex: 6,
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
      case CalcMode.currency:
        return _CurrencySection(context);
    }
  }

  static Widget _MatrixSection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_on_rounded, size: 40, color: ColorTokens.accentBlue.withOpacity(0.5)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatrixEditorScreen())),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open Matrix Editor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
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
          Icon(Icons.analytics_rounded, size: 40, color: ColorTokens.accentGreen.withOpacity(0.5)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsInputScreen())),
            icon: const Icon(Icons.table_chart, size: 16),
            label: const Text('Open Data Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
          Icon(Icons.swap_horiz_rounded, size: 40, color: ColorTokens.accentPurple.withOpacity(0.5)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitConverterScreen())),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open Unit Converter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _CurrencySection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.currency_exchange_rounded, size: 40, color: ColorTokens.accentOrange.withOpacity(0.5)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyConverterScreen())),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open Currency Converter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
