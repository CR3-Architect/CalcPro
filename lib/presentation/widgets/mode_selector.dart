import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/enums/calc_mode.dart';
import '../../core/theme/color_tokens.dart';

/// Mode selector tab bar
class ModeSelector extends StatelessWidget {
  final TabController controller;
  final bool isDark;
  
  const ModeSelector({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        labelColor: ColorTokens.electricCyan,
        unselectedLabelColor: isDark
            ? ColorTokens.darkOnSurface.withOpacity(0.5)
            : ColorTokens.lightOnSurface.withOpacity(0.5),
        indicatorColor: ColorTokens.electricCyan,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: CalcMode.values.map((mode) {
          return Tab(text: mode.displayName);
        }).toList(),
      ),
    );
  }
}
