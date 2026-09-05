import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/bloc/calculator_cubit.dart';
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
    _currentTheme = AppThemeMode.values[_themeIndex];
  }
  
  void _onThemeChanged(int index) {
    setState(() {
      _themeIndex = index;
      _currentTheme = AppThemeMode.values[index];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CalculatorCubit>(
          create: (_) => CalculatorCubit(),
        ),
        BlocProvider<HistoryCubit>(
          create: (_) => HistoryCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Listen for theme changes from settings
          return _ThemeScope(
            themeIndex: _themeIndex,
            onThemeChanged: _onThemeChanged,
            child: MaterialApp(
              title: 'CalcPro Studio',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getTheme(_currentTheme),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const CalculatorScreen(),
            ),
          );
        },
      ),
    );
  }
}

/// Inherited widget to provide theme change callback
class _ThemeScope extends InheritedWidget {
  final int themeIndex;
  final ValueChanged<int> onThemeChanged;
  
  const _ThemeScope({
    required this.themeIndex,
    required this.onThemeChanged,
    required super.child,
  });
  

  
  @override
  bool updateShouldNotify(_ThemeScope oldWidget) {
    return themeIndex != oldWidget.themeIndex;
  }
}
