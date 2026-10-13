import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/enums/angle_mode.dart';
import '../../core/enums/number_base.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/color_tokens.dart';
import '../bloc/calculator_cubit.dart';
import '../bloc/calculator_state.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fg = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    final subFg = isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface;

    return Scaffold(
      backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600, color: fg, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: fg),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Appearance', fg),
          _Card(
            isDark,
            [
              // Theme — reads live from cubit so it stays in sync
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (p, c) => p.themeIndex != c.themeIndex,
                builder: (context, state) {
                  final mode = AppThemeMode.values[
                      state.themeIndex.clamp(0, AppThemeMode.values.length - 1)];
                  return ListTile(
                    leading: Icon(Icons.palette_rounded, color: subFg),
                    title: Text('Theme', style: TextStyle(color: fg)),
                    subtitle: Text(
                      mode.name[0].toUpperCase() + mode.name.substring(1),
                      style: TextStyle(color: subFg, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subFg),
                    onTap: () => _showThemeDialog(context, state.themeIndex),
                  );
                },
              ),
              const Divider(height: 1),
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (p, c) => p.highContrastMode != c.highContrastMode,
                builder: (context, state) {
                  return SwitchListTile(
                    secondary: Icon(Icons.contrast, color: subFg),
                    title: Text('High Contrast', style: TextStyle(color: fg)),
                    subtitle: Text(
                      'Boosted visibility',
                      style: TextStyle(color: subFg, fontSize: 13),
                    ),
                    value: state.highContrastMode,
                    activeThumbColor: Colors.white,
                    activeTrackColor: ColorTokens.electricCyan,
                    inactiveThumbColor: subFg,
                    onChanged: (_) => context.read<CalculatorCubit>().toggleHighContrast(),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SectionHeader('Calculator', fg),
          _Card(
            isDark,
            [
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (p, c) => p.angleMode != c.angleMode,
                builder: (context, state) => ListTile(
                  leading: Icon(Icons.code_rounded, color: subFg),
                  title: Text('Angle Mode', style: TextStyle(color: fg)),
                  subtitle: Text(state.angleMode.displayName,
                      style: TextStyle(color: subFg, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: subFg),
                  onTap: () => _showAngleModeDialog(context, state),
                ),
              ),
              const Divider(height: 1),
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (p, c) => p.numberBase != c.numberBase,
                builder: (context, state) => ListTile(
                  leading: Icon(Icons.pin_rounded, color: subFg),
                  title: Text('Default Number Base', style: TextStyle(color: fg)),
                  subtitle: Text(state.numberBase.displayName,
                      style: TextStyle(color: subFg, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: subFg),
                  onTap: () => _showNumberBaseDialog(context, state),
                ),
              ),
              const Divider(height: 1),
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (p, c) => p.precision != c.precision,
                builder: (context, state) {
                  final labels = ['Auto', '2', '4', '6', '8', '10'];
                  final values = [0, 2, 4, 6, 8, 10];
                  final idx = values.indexOf(state.precision);
                  return ListTile(
                    leading: Icon(Icons.straighten_rounded, color: subFg),
                    title: Text('Decimal Precision', style: TextStyle(color: fg)),
                    subtitle: Text(
                      labels[idx < 0 ? 0 : idx],
                      style: TextStyle(color: subFg, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: subFg),
                    onTap: () => _showPrecisionDialog(context, state, labels, values),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SectionHeader('Feedback', fg),
          _Card(
            isDark,
            [
              BlocBuilder<CalculatorCubit, CalculatorState>(
                buildWhen: (p, c) => p.hapticFeedback != c.hapticFeedback,
                builder: (context, state) => SwitchListTile(
                  secondary: Icon(Icons.vibration_rounded, color: subFg),
                  title: Text('Haptic Feedback', style: TextStyle(color: fg)),
                  subtitle: Text('Vibrate on press',
                      style: TextStyle(color: subFg, fontSize: 13)),
                  value: state.hapticFeedback,
                  activeThumbColor: Colors.white,
                  activeTrackColor: ColorTokens.electricCyan,
                  inactiveThumbColor: subFg,
                  onChanged: (_) => context.read<CalculatorCubit>().toggleHapticFeedback(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SectionHeader('About', fg),
          _Card(
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
                title: Text('CalcPro Studio', style: TextStyle(color: fg)),
                subtitle: Text('Version 1.0.0',
                    style: TextStyle(color: subFg, fontSize: 13)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.code_rounded, color: subFg),
                title: Text('Developer', style: TextStyle(color: fg)),
                subtitle: Text('Atiqullah', style: TextStyle(color: subFg, fontSize: 13)),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, int current) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
        title: Text('Theme',
            style: TextStyle(
                color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.asMap().entries.map((entry) {
            return RadioListTile<int>(
              value: entry.key,
              groupValue: current,
              activeColor: ColorTokens.electricCyan,
              fillColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? ColorTokens.electricCyan
                      : null),
              title: Text(entry.value.name[0].toUpperCase() + entry.value.name.substring(1),
                  style: TextStyle(
                      color: isDark
                          ? ColorTokens.darkOnBackground
                          : ColorTokens.lightOnBackground)),
              onChanged: (v) {
                if (v != null) {
                  context.read<CalculatorCubit>().setTheme(v);
                  Navigator.pop(dialogCtx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAngleModeDialog(BuildContext context, CalculatorState state) {
    showDialog(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        title: const Text('Angle Mode'),
        children: AngleMode.values.map((mode) {
          return SimpleDialogOption(
            onPressed: () {
              context.read<CalculatorCubit>().setAngleMode(mode);
              Navigator.pop(dialogCtx);
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
      builder: (dialogCtx) => SimpleDialog(
        title: const Text('Number Base'),
        children: NumberBase.values.map((base) {
          return SimpleDialogOption(
            onPressed: () {
              context.read<CalculatorCubit>().setNumberBase(base);
              Navigator.pop(dialogCtx);
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
      builder: (dialogCtx) => SimpleDialog(
        title: const Text('Decimal Precision'),
        children: labels.asMap().entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () {
              context.read<CalculatorCubit>().setPrecision(values[entry.key]);
              Navigator.pop(dialogCtx);
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: color.withOpacity(0.55),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _Card(this.isDark, this.children);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(children: children),
    );
  }
}
