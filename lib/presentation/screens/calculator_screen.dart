import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
import '../widgets/mode_selector.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'unit_converter_screen.dart';
import 'matrix_editor_screen.dart';
import 'stats_input_screen.dart';

/// Main calculator screen with tab navigation
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: CalcMode.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<CalculatorCubit>().setMode(CalcMode.values[_tabController.index]);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Bar ---
            _buildTopBar(context, isDark),
            
            // --- Display Area ---
            Expanded(
              flex: 2,
              child: _buildDisplayArea(context, isDark),
            ),
            
            // --- Mode Selector ---
            ModeSelector(
              controller: _tabController,
              isDark: isDark,
            ),
            
            // --- Keypad Area ---
            Expanded(
              flex: 5,
              child: _buildKeypadArea(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // App name
          Text(
            'CalcPro',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
            ),
          ),
          Text(
            ' Studio',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: ColorTokens.electricCyan,
            ),
          ),
          const Spacer(),
          // Undo
          BlocBuilder<CalculatorCubit, CalculatorState>(
            buildWhen: (prev, curr) => prev.canUndo != curr.canUndo,
            builder: (context, state) {
              return IconButton(
                onPressed: state.canUndo ? () => context.read<CalculatorCubit>().undo() : null,
                icon: const Icon(Icons.undo_rounded, size: 20),
                color: isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface,
              );
            },
          ),
          // Redo
          BlocBuilder<CalculatorCubit, CalculatorState>(
            buildWhen: (prev, curr) => prev.canRedo != curr.canRedo,
            builder: (context, state) {
              return IconButton(
                onPressed: state.canRedo ? () => context.read<CalculatorCubit>().redo() : null,
                icon: const Icon(Icons.redo_rounded, size: 20),
                color: isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface,
              );
            },
          ),
          // History
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history_rounded, size: 22),
            color: isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface,
          ),
          // Settings
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_rounded, size: 22),
            color: isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDisplayArea(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // History tape (recent 3 entries)
          const Expanded(
            flex: 1,
            child: HistoryTape(),
          ),
          const SizedBox(height: 4),
          // Expression line
          const Expanded(
            flex: 1,
            child: ExpressionDisplay(),
          ),
          const SizedBox(height: 4),
          // Result line
          const Expanded(
            flex: 2,
            child: ResultDisplay(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildKeypadArea() {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        switch (state.mode) {
          case CalcMode.standard:
            return const StandardKeypad();
          case CalcMode.scientific:
            return const ScientificKeypad();
          case CalcMode.calculus:
            return const CalculusKeypad();
          case CalcMode.matrix:
            return _buildMatrixSection(context);
          case CalcMode.complex:
            return const ScientificKeypad(); // Reuse with complex buttons
          case CalcMode.stats:
            return _buildStatsSection(context);
          case CalcMode.programmer:
            return const ProgrammerKeypad();
          case CalcMode.unitConverter:
            return _buildUnitConverterSection(context);
        }
      },
    );
  }
  
  Widget _buildMatrixSection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_on_rounded, size: 48, color: ColorTokens.accentBlue.withOpacity(0.6)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MatrixEditorScreen()),
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Matrix Editor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          const MatrixKeypad(),
        ],
      ),
    );
  }
  
  Widget _buildStatsSection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_rounded, size: 48, color: ColorTokens.accentGreen.withOpacity(0.6)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsInputScreen()),
            ),
            icon: const Icon(Icons.table_chart),
            label: const Text('Open Data Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUnitConverterSection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz_rounded, size: 48, color: ColorTokens.accentPurple.withOpacity(0.6)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UnitConverterScreen()),
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Unit Converter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
