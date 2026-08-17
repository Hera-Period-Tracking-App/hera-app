import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/calendar/widgets/calendar_month_section.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';

class CalendarLegendCard extends StatelessWidget {
  const CalendarLegendCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();
    final l10n = AppLocalizations.of(context);

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
                label: l10n.phaseMenstruation,
              ),

              const SizedBox(height: 10),

              CalendarLegendItem(
                color: (phaseColors?.ovulation ??
                        theme.colorScheme.secondary)
                    .withValues(alpha: 0.85),
                label: l10n.fertile,
              ),

              const SizedBox(height: 10),

              CalendarLegendItem(
                color: (phaseColors?.ovulation ??
                        theme.colorScheme.secondary)
                    .withValues(alpha: 0.85),
                label: l10n.ovulation,
              ),

              const SizedBox(height: 10),

              CalendarLegendItem(
                color: Colors.transparent,
                label: l10n.today,
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
