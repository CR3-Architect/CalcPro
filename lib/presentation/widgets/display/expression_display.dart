import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/color_tokens.dart';
import '../../bloc/calculator_cubit.dart';
import '../../bloc/calculator_state.dart';

/// Syntax-highlighted expression display (perf: no GoogleFonts per frame)
class ExpressionDisplay extends StatelessWidget {
  const ExpressionDisplay({super.key});

  static const TextStyle _baseStyle = TextStyle(
    fontFamily: 'Roboto Mono',
    fontSize: 22,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (prev, curr) => prev.displayExpression != curr.displayExpression,
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (state.displayExpression.isEmpty) {
          return Align(
            alignment: Alignment.centerRight,
            child: Text(
              '0',
              style: _baseStyle.copyWith(
                color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                    .withOpacity(0.25),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Align(
            alignment: Alignment.centerRight,
            child: _buildHighlightedExpression(state.displayExpression, isDark),
          ),
        );
      },
    );
  }

  Widget _buildHighlightedExpression(String expression, bool isDark) {
    final spans = <TextSpan>[];
    final buffer = StringBuffer();
    String lastType = '';

    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];
      String currentType = _getCharType(char);

      if (currentType != lastType && buffer.isNotEmpty) {
        spans.add(_createSpan(buffer.toString(), lastType, isDark));
        buffer.clear();
      }

      buffer.write(char);
      lastType = currentType;
    }

    if (buffer.isNotEmpty) {
      spans.add(_createSpan(buffer.toString(), lastType, isDark));
    }

    return RichText(
      text: TextSpan(children: spans, style: _baseStyle),
      maxLines: 1,
    );
  }

  String _getCharType(String char) {
    if (RegExp(r'[0-9.]').hasMatch(char)) return 'number';
    if ('+-×÷%'.contains(char)) return 'operator';
    if ('()'.contains(char)) return 'parenthesis';
    if (RegExp(r'[a-zA-Zπeφ]').hasMatch(char)) return 'function';
    return 'default';
  }

  TextSpan _createSpan(String text, String type, bool isDark) {
    Color color;

    switch (type) {
      case 'number':
        color = isDark ? ColorTokens.syntaxNumber : ColorTokens.syntaxNumberLight;
        break;
      case 'operator':
        color = isDark ? ColorTokens.syntaxOperator : ColorTokens.syntaxOperatorLight;
        break;
      case 'parenthesis':
        color = isDark ? ColorTokens.syntaxParenthesis : ColorTokens.syntaxParenthesisLight;
        break;
      case 'function':
        color = isDark ? ColorTokens.syntaxFunction : ColorTokens.syntaxFunctionLight;
        break;
      default:
        color = isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface;
    }

    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 22,
        fontWeight: type == 'operator' ? FontWeight.w600 : FontWeight.w400,
        fontFamily: 'Roboto Mono',
      ),
    );
  }
}
