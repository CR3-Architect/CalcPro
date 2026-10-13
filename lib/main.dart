import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/bloc/calculator_cubit.dart';
import 'presentation/bloc/calculator_state.dart';
import 'presentation/bloc/history_cubit.dart';
import 'presentation/screens/calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final themeIndex = prefs.getInt('themeMode') ?? 0;
  runApp(CalcProApp(initialThemeIndex: themeIndex));
}

/// CalcPro Studio Application
class CalcProApp extends StatefulWidget {
  final int initialThemeIndex;
  const CalcProApp({super.key, required this.initialThemeIndex});

  @override
  State<CalcProApp> createState() => _CalcProAppState();
}

class _CalcProAppState extends State<CalcProApp> {
  late final CalculatorCubit _calcCubit;
  late final HistoryCubit _historyCubit;

  // Cache themes so switching is instant (no re-creation each rebuild)
  static final Map<String, ThemeData> _themeCache = {};

  static ThemeData _cachedTheme(AppThemeMode mode, bool highContrast) {
    final key = '${mode.name}_$highContrast';
    return _themeCache.putIfAbsent(
      key,
      () => AppTheme.getTheme(mode, highContrast: highContrast),
    );
  }

  @override
  void initState() {
    super.initState();
    _calcCubit = CalculatorCubit(initialThemeIndex: widget.initialThemeIndex);
    _historyCubit = HistoryCubit();
  }

  @override
  void dispose() {
    _calcCubit.close();
    _historyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CalculatorCubit>.value(value: _calcCubit),
        BlocProvider<HistoryCubit>.value(value: _historyCubit),
      ],
      child: BlocListener<CalculatorCubit, CalculatorState>(
        listenWhen: (prev, curr) => prev.history != curr.history,
        listener: (context, state) => _historyCubit.loadHistory(),
        child: BlocBuilder<CalculatorCubit, CalculatorState>(
          buildWhen: (prev, curr) =>
              prev.themeIndex != curr.themeIndex ||
              prev.highContrastMode != curr.highContrastMode,
          builder: (context, calcState) {
            final themeMode = AppThemeMode.values[
                calcState.themeIndex.clamp(0, AppThemeMode.values.length - 1)];
            return MaterialApp(
              title: 'CalcPro',
              debugShowCheckedModeBanner: false,
              theme: _cachedTheme(themeMode, calcState.highContrastMode),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const CalculatorScreen(),
            );
          },
        ),
      ),
    );
  }
}
