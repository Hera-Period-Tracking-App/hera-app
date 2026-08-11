import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/calendar/widgets/calendar_month_section.dart';

class CalendarLegendCard extends StatelessWidget {
  const CalendarLegendCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              CalendarLegendItem(
                color: Colors.red,
                label: 'Menstruation',
              ),

              const SizedBox(height: 10),

              CalendarLegendItem(
                color: (phaseColors?.follicular ??
                        theme.colorScheme.secondary)
                    .withValues(alpha: 0.85),
                label: 'Fertile',
              ),

              const SizedBox(height: 10),

              CalendarLegendItem(
                color: (phaseColors?.ovulation ??
                        theme.colorScheme.secondary)
                    .withValues(alpha: 0.85),
                label: 'Ovulation',
              ),

              const SizedBox(height: 10),

              const CalendarLegendItem(
                color: Colors.transparent,
                label: 'Today',
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
