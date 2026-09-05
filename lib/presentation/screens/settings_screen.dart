import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/enums/angle_mode.dart';
import '../../core/enums/number_base.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/color_tokens.dart';
import '../bloc/calculator_cubit.dart';
import '../bloc/calculator_state.dart';


/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _themeModeIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeModeIndex = prefs.getInt('themeMode') ?? 0;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Appearance ---
          _buildSectionHeader('Appearance', isDark),
          _buildCard(
            isDark,
            [
              // Theme switcher
              ListTile(
                leading: const Icon(Icons.palette_rounded),
                title: const Text('Theme'),
                subtitle: Text(AppThemeMode.values[_themeModeIndex].name.toUpperCase()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context),
              ),
              const Divider(height: 1),
              // High contrast mode
              BlocBuilder<CalculatorCubit, CalculatorState>(
                builder: (context, state) {
                  return SwitchListTile(
                    secondary: const Icon(Icons.contrast),
                    title: const Text('High Contrast Mode'),
                    subtitle: const Text('Increased visibility for accessibility'),
                    value: state.highContrastMode,
                    onChanged: (_) => context.read<CalculatorCubit>().toggleHighContrast(),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // --- Calculator ---
          _buildSectionHeader('Calculator', isDark),
          _buildCard(
            isDark,
            [
              // Angle mode
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (prev, curr) => prev.angleMode != curr.angleMode,
                builder: (context, state) {
                  return ListTile(
                    leading: const Icon(Icons.code_rounded),
                    title: const Text('Angle Mode'),
                    subtitle: Text(state.angleMode.displayName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAngleModeDialog(context, state),
                  );
                },
              ),
              const Divider(height: 1),
              // Number base
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (prev, curr) => prev.numberBase != curr.numberBase,
                builder: (context, state) {
                  return ListTile(
                    leading: const Icon(Icons.pin_rounded),
                    title: const Text('Default Number Base'),
                    subtitle: Text(state.numberBase.displayName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showNumberBaseDialog(context, state),
                  );
                },
              ),
              const Divider(height: 1),
              // Precision
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (prev, curr) => prev.precision != curr.precision,
                builder: (context, state) {
                  final precisions = ['Auto', '2', '4', '6', '8', '10'];
                  final precisionValues = [0, 2, 4, 6, 8, 10];
                  return ListTile(
                    leading: const Icon(Icons.straighten_rounded),
                    title: const Text('Decimal Precision'),
                    subtitle: Text(precisions[precisionValues.indexOf(state.precision)]),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPrecisionDialog(context, state, precisions, precisionValues),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // --- Feedback ---
          _buildSectionHeader('Feedback', isDark),
          _buildCard(
            isDark,
            [
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (prev, curr) => prev.hapticFeedback != curr.hapticFeedback,
                builder: (context, state) {
                  return SwitchListTile(
                    secondary: const Icon(Icons.vibration_rounded),
                    title: const Text('Haptic Feedback'),
                    subtitle: const Text('Vibrate on button press'),
                    value: state.hapticFeedback,
                    onChanged: (_) => context.read<CalculatorCubit>().toggleHapticFeedback(),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // --- About ---
          _buildSectionHeader('About', isDark),
          _buildCard(
            isDark,
            [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: ColorTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '∞',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: const Text('CalcPro Studio'),
                subtitle: const Text('Version 1.0.0'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Professional Scientific Calculator'),
                subtitle: Text(
                  'Built for BS-level Computer Science and Math students.\n'
                  'Features: 8 calculator modes, 100+ units, LaTeX display.',
                ),
                isThreeLine: true,
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.code_rounded),
                title: Text('Developer'),
                subtitle: Text('CalcPro Team'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: ColorTokens.electricCyan,
        ),
      ),
    );
  }
  
  Widget _buildCard(bool isDark, List<Widget> children) {
    return Card(
      color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
  
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: AppThemeMode.values.asMap().entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => _themeModeIndex = entry.key);
              context.read<CalculatorCubit>().setTheme(entry.key);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(
                  _themeModeIndex == entry.key
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _themeModeIndex == entry.key
                      ? ColorTokens.electricCyan
                      : null,
                ),
                const SizedBox(width: 12),
                Text(entry.value.name[0].toUpperCase() + entry.value.name.substring(1)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  void _showAngleModeDialog(BuildContext context, CalculatorState state) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Angle Mode'),
        children: AngleMode.values.map((mode) {
          return SimpleDialogOption(
            onPressed: () {
              context.read<CalculatorCubit>().setAngleMode(mode);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(
                  state.angleMode == mode
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: state.angleMode == mode ? ColorTokens.electricCyan : null,
                ),
                const SizedBox(width: 12),
                Text('${mode.displayName} (${mode.symbol})'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  void _showNumberBaseDialog(BuildContext context, CalculatorState state) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Number Base'),
        children: NumberBase.values.map((base) {
          return SimpleDialogOption(
            onPressed: () {
              context.read<CalculatorCubit>().setNumberBase(base);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(
                  state.numberBase == base
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: state.numberBase == base ? ColorTokens.electricCyan : null,
                ),
                const SizedBox(width: 12),
                Text('${base.displayName} (${base.abbreviation})'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  void _showPrecisionDialog(
    BuildContext context,
    CalculatorState state,
    List<String> labels,
    List<int> values,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Decimal Precision'),
        children: labels.asMap().entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () {
              context.read<CalculatorCubit>().setPrecision(values[entry.key]);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(
                  state.precision == values[entry.key]
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: state.precision == values[entry.key]
                      ? ColorTokens.electricCyan
                      : null,
                ),
                const SizedBox(width: 12),
                Text(entry.value),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
