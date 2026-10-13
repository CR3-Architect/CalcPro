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
  
  // Load saved theme preference
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
  late int _themeIndex;
  late AppThemeMode _currentTheme;
  
  @override
  void initState() {
    super.initState();
    _themeIndex = widget.initialThemeIndex;
    _currentTheme = AppThemeMode.values[_themeIndex.clamp(0, AppThemeMode.values.length - 1)];
  }
  
  void _onThemeChanged(int index) {
    final clamped = index.clamp(0, AppThemeMode.values.length - 1);
    setState(() {
      _themeIndex = clamped;
      _currentTheme = AppThemeMode.values[clamped];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CalculatorCubit>(
          create: (_) => CalculatorCubit(initialThemeIndex: _themeIndex),
        ),
        BlocProvider<HistoryCubit>(
          create: (_) => HistoryCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Sync history: when CalculatorCubit history changes, reload HistoryCubit
          return BlocListener<CalculatorCubit, CalculatorState>(
            listenWhen: (prev, curr) => prev.history != curr.history,
            listener: (context, state) {
              context.read<HistoryCubit>().loadHistory();
            },
            child: BlocListener<CalculatorCubit, CalculatorState>(
              listenWhen: (prev, curr) => prev.themeIndex != curr.themeIndex,
              listener: (context, state) {
                _onThemeChanged(state.themeIndex);
              },
              child: BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (prev, curr) =>
                    prev.themeIndex != curr.themeIndex ||
                    prev.highContrastMode != curr.highContrastMode,
                builder: (context, calcState) {
                  return MaterialApp(
                    title: 'CalcPro Studio',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.getTheme(
                      _currentTheme,
                      highContrast: calcState.highContrastMode,
                    ),
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
        },
      ),
    );
  }
}
