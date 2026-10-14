import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/color_tokens.dart';
import '../../bloc/calculator_cubit.dart';
import '../../bloc/calculator_state.dart';

/// Scrollable recent history tape showing last 3 calculations
class HistoryTape extends StatelessWidget {
  const HistoryTape({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      buildWhen: (prev, curr) => prev.history != curr.history,
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        if (state.history.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Show last 3 entries (most recent at bottom)
        final recentEntries = state.history.take(3).toList();
        recentEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: recentEntries.map((entry) {
            return GestureDetector(
              onTap: () => context.read<CalculatorCubit>().recallHistory(entry),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      entry.expression,
                      style: TextStyle(fontFamily: 'monospace', 
                        fontSize: 12,
                        color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                            .withOpacity(0.4),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '= ${entry.result}',
                      style: TextStyle(fontFamily: 'monospace', 
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                            .withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
