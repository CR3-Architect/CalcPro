import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/color_tokens.dart';
import '../../bloc/calculator_cubit.dart';
import '../../bloc/calculator_state.dart';

/// Large auto-sizing result display (perf: no GoogleFonts per frame)
class ResultDisplay extends StatefulWidget {
  const ResultDisplay({super.key});

  @override
  State<ResultDisplay> createState() => _ResultDisplayState();
}

class _ResultDisplayState extends State<ResultDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _previousResult = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (prev, curr) => prev.result != curr.result || prev.error != curr.error,
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (state.result != _previousResult) {
          _previousResult = state.result;
          _controller.reset();
          _controller.forward();
        }

        if (state.error.isNotEmpty) {
          return _buildError(state.error);
        }

        final displayResult = state.formattedResult;
        if (displayResult.isEmpty) {
          return const SizedBox.shrink();
        }

        double fontSize = 40;
        if (displayResult.length > 16) {
          fontSize = 22;
        } else if (displayResult.length > 12) {
          fontSize = 28;
        } else if (displayResult.length > 9) {
          fontSize = 34;
        }

        return GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: displayResult));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied: $displayResult'),
                duration: const Duration(seconds: 1),
                backgroundColor: ColorTokens.accentGreen,
                behavior: SnackBarBehavior.floating,
                width: 200,
              ),
            );
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                displayResult,
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(String error) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ColorTokens.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          error,
          style: const TextStyle(
            fontSize: 14,
            color: ColorTokens.error,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
