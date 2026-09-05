import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/color_tokens.dart';
import '../../bloc/calculator_cubit.dart';
import '../../bloc/calculator_state.dart';

/// Large auto-sizing result display
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
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        // Trigger animation when result changes
        if (state.result != _previousResult) {
          _previousResult = state.result;
          _controller.reset();
          _controller.forward();
        }
        
        if (state.error.isNotEmpty) {
          return _buildError(state.error, isDark);
        }
        
        final displayResult = state.formattedResult;
        
        if (displayResult.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Auto-size font based on result length
        double fontSize = 36;
        if (displayResult.length > 15) {
          fontSize = 20;
        } else if (displayResult.length > 12) {
          fontSize = 24;
        } else if (displayResult.length > 9) {
          fontSize = 30;
        }
        
        return GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: displayResult));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied: $displayResult'),
                duration: const Duration(seconds: 1),
                backgroundColor: ColorTokens.accentGreen,
              ),
            );
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                displayResult,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
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
  
  Widget _buildError(String error, bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ColorTokens.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          error,
          style: GoogleFonts.inter(
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
